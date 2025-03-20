/**
 * @license BSD-3-Clause
 * Copyright (c) 2022, ッツ Reader Authors
 * All rights reserved.
 */

import type { IDBPDatabase } from 'idb';
import { Subject, from } from 'rxjs';
import { map, shareReplay, startWith, switchMap } from 'rxjs/operators';
import type BooksDb from './versions/books-db';
import type { BooksDbBookData, BooksDbBookmarkData } from './versions/books-db';
import type BooksDbV3 from './versions/v3/books-db-v3';
import { blobToBase64, convertBase64ToBlob, convertBase64ToBlobMap } from '$lib/functions/blob';

const LAST_ITEM_KEY = 0;

// Fetches data from flutter app when in app
// Fetches data from indexed db when isolated (for testing on Chrome)
export class DatabaseService {
  private db$ = from(this.db).pipe(shareReplay({ refCount: true, bufferSize: 1 }));

  isReady$ = this.db$.pipe(map((db) => !!db));

  dataListChanged$ = new Subject<void>();

  runForEnvironment = (webFunction: () => any, flutterFunction: () => any) => window.flutter_inappwebview == null ? webFunction() : flutterFunction();

  getBookById = async (bookId: number) => this.runForEnvironment(
    () => this.getData(bookId),
    async () => {
      const data = await window.flutter_inappwebview?.callHandler('getBookById', bookId);
      // convert cover image and blobs (illustrations) for book
      data['coverImage'] = convertBase64ToBlob(data['coverImage']);
      data['blobs'] = convertBase64ToBlobMap(data['blobMap']);
      return data;
    });

  getBooks = async (db: IDBPDatabase<BooksDbV3>) => this.runForEnvironment(
    () => db.getAll('data'),
    async () => {
      let data = await window.flutter_inappwebview?.callHandler('getBooks');
      if (data != null) {
        data = data.map((book: any) => {
          // we only convert cover image and not blobs as we do not need images in books
          book['coverImage'] = convertBase64ToBlob(book['coverImage']);
          return book;
        })
      }
      return data;
    });

  addBook = async (data: Omit<BooksDbBookData, 'id'>) => this.runForEnvironment(
    () => this._upsertData(data),
    async () => {
      if (data["coverImage"] != null) {
        data["coverImage"] = await blobToBase64(data["coverImage"] as Blob) as string;
      }
      const blobs = await Promise.all(
        Object.keys(data["blobs"]).map(async (blobKey) => {
          return {
            'key': blobKey,
            'base64Data': await blobToBase64(data["blobs"][blobKey])
          };
        })
      );
      // data["blobs"] = blobs;
      const newDataId = await window.flutter_inappwebview?.callHandler('setBook', {
        ...data,
        'blobs': blobs
      });
      return newDataId;
    });

  deleteBooksByIds = async (ids: number[]) => this.runForEnvironment(
    async () => {
      this._deleteData(ids);
    }, async () => {
      await window.flutter_inappwebview?.callHandler('deleteBooksByIds', ids);
      this.dataListChanged$.next();
    });

  getBookmarks = async (db: IDBPDatabase<BooksDbV3>) => this.runForEnvironment(
    () => db.getAll('bookmark'),
    () => window.flutter_inappwebview?.callHandler('getBookmarks'));

  getBookmarkByBookId = async (dataId: number) => this.runForEnvironment(
    async () => {
      const db = await this.db;
      return db.get('bookmark', dataId);
    }, () => window.flutter_inappwebview?.callHandler('getBookmarkByBookId', dataId)
  );

  setBookmark = async (bookmarkData: BooksDbBookmarkData) => this.runForEnvironment(
    async () => {
      const db = await this.db;
      const result = await db.put('bookmark', bookmarkData);
      this.bookmarksChanged$.next();
      return result;
    }, async () => {
      const result = await window.flutter_inappwebview?.callHandler('setBookmark', bookmarkData);
      this.bookmarksChanged$.next();
      return result;
    });

  dataList$ = this.dataListChanged$.pipe(
    startWith(0),
    switchMap(() => this.db$),
    switchMap((db) => this.getBooks(db)),
    shareReplay({ refCount: true, bufferSize: 1 })
  );

  dataIds$ = this.dataListChanged$.pipe(
    startWith(0),
    switchMap(() => this.db$),
    switchMap((db) => db.getAllKeys('data')),
    shareReplay({ refCount: true, bufferSize: 1 })
  );

  bookmarksChanged$ = new Subject<void>();

  bookmarks$ = this.bookmarksChanged$.pipe(
    startWith(0),
    switchMap(() => this.db$),
    switchMap((db) => this.getBookmarks(db)),
    shareReplay({ refCount: true, bufferSize: 1 })
  );

  lastItemChanged$ = new Subject<void>();

  lastItem$ = this.lastItemChanged$.pipe(
    startWith(0),
    switchMap(() => this.db$),
    switchMap((db) => db.get('lastItem', LAST_ITEM_KEY)),
    shareReplay({ refCount: true, bufferSize: 1 })
  );

  constructor(public db: Promise<IDBPDatabase<BooksDb>>) { }

  async getData(dataId: number) {
    if (!Number.isNaN(dataId)) {
      const db = await this.db;
      return db.get('data', dataId);
    }
    return undefined;
  }

  async _upsertData(data: Omit<BooksDbBookData, 'id'>) {
    const db = await this.db;

    let dataId: number;

    const tx = db.transaction('data', 'readwrite');
    const { store } = tx;
    const oldId = await store.index('title').getKey(data.title);

    if (oldId) {
      dataId = await store.put({
        ...data,
        id: oldId
      });
    } else {
      // Until https://github.com/jakearchibald/idb/issues/150 resolves
      const bookDataWithoutKey: Omit<BooksDbBookData, 'id'> = data;
      dataId = await store.add(bookDataWithoutKey as BooksDbBookData);
    }
    await tx.done;
    this.dataListChanged$.next();
    return dataId;
  }

  async _deleteData(dataIds: number[]) {
    const db = await this.db;

    const lastItemObj = await db.get('lastItem', LAST_ITEM_KEY);
    const bookmarkIds = await db.getAllKeys('bookmark');

    const deleteBookPromises = dataIds.map((id) =>
      this._deleteSingleData(id, {
        lastItem: lastItemObj?.dataId,
        bookmarkIds: new Set(bookmarkIds)
      })
    );
    await Promise.all(deleteBookPromises);
  }

  // not used with flutter
  async putLastItem(dataId: number) {
    const db = await this.db;
    const result = await db.put('lastItem', { dataId }, LAST_ITEM_KEY);
    this.lastItemChanged$.next();
    return result;
  }

  // not used with flutter
  async deleteLastItem() {
    const db = await this.db;
    await db.delete('lastItem', LAST_ITEM_KEY);
    this.lastItemChanged$.next();
  }

  private async _deleteSingleData(
    dataId: number,
    cachedData: {
      bookmarkIds: Set<number>;
      lastItem: number | undefined;
    }
  ) {
    const db = await this.db;

    const storeNames: ('data' | 'bookmark' | 'lastItem')[] = ['data'];

    const shouldDeleteLastItem = cachedData.lastItem === dataId;
    const shouldDeleteBookmark = cachedData.bookmarkIds.has(dataId);

    if (shouldDeleteLastItem) {
      storeNames.push('lastItem');
    }
    if (shouldDeleteBookmark) {
      storeNames.push('bookmark');
    }

    const tx = db.transaction(storeNames, 'readwrite');

    if (shouldDeleteLastItem) {
      await tx.objectStore('lastItem').delete(LAST_ITEM_KEY);
    }
    if (shouldDeleteBookmark) {
      await tx.objectStore('bookmark').delete(dataId);
    }
    await tx.objectStore('data').delete(dataId);
    await tx.done;

    if (shouldDeleteLastItem) {
      this.lastItemChanged$.next();
    }
    this.dataListChanged$.next();
  }
}
