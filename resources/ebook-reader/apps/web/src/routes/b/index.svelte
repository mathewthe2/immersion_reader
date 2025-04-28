<script lang="ts">
  import {
    EMPTY,
    filter,
    fromEvent,
    map,
    share,
    shareReplay,
    startWith,
    switchMap,
    tap,
    timer
  } from 'rxjs';
  import { quintInOut } from 'svelte/easing';
  import { fly } from 'svelte/transition';
  import { page } from '$app/stores';
  import { goto } from '$app/navigation';
  import BookReader from '$lib/components/book-reader/book-reader.svelte';
  import type {
    AutoScroller,
    BookmarkManager,
    PageManager
  } from '$lib/components/book-reader/types';
  import StyleSheetRenderer from '$lib/components/style-sheet-renderer.svelte';
  import type { BooksDbBookmarkData } from '$lib/data/database/books-db/versions/books-db';
  import {
    autoBookmark$,
    autoPositionOnResize$,
    avoidPageBreak$,
    bookReaderKeybindMap$,
    database,
    firstDimensionMargin$,
    fontFamilyGroupOne$,
    fontFamilyGroupTwo$,
    fontSize$,
    furiganaStyle$,
    hideFurigana$,
    hideSpoilerImage$,
    multiplier$,
    pageColumns$,
    secondDimensionMaxValue$,
    theme$,
    verticalMode$,
    writingMode$,
    viewMode$
  } from '$lib/data/store';
  import BookReaderHeader from '$lib/components/book-reader/book-reader-header.svelte';
  import BookToc from '$lib/components/book-reader/book-toc/book-toc.svelte';
  import { availableThemes } from '$lib/data/theme-option';
  import { fullscreenManager } from '$lib/data/fullscreen-manager';
  import loadBookData from '$lib/functions/book-data-loader/load-book-data';
  import { formatPageTitle } from '$lib/functions/format-page-title';
  import { iffBrowser } from '$lib/functions/rxjs/iff-browser';
  import { readableToObservable } from '$lib/functions/rxjs/readable-to-observable';
  import { reduceToEmptyString } from '$lib/functions/rxjs/reduce-to-empty-string';
  import { takeWhenBrowser } from '$lib/functions/rxjs/take-when-browser';
  import { tapDom } from '$lib/functions/rxjs/tap-dom';
  import {
    getChapterData,
    nextChapter$,
    sectionList$,
    sectionProgress$,
    tocIsOpen$
  } from '$lib/components/book-reader/book-toc/book-toc';
  import { toDevIsOpen$ } from '$lib/components/book-reader/dev-tools/dev-tools';
  import { clickOutside } from '$lib/functions/use-click-outside';
  import { onKeydownReader } from './on-keydown-reader';
  import { onMount } from 'svelte';
  import type { Section } from '$lib/data/database/books-db/versions/v3/books-db-v3';
  import DevTools from '$lib/components/book-reader/dev-tools/dev-tools.svelte';

  export let showDevMenu: boolean = true;
  let showHeader = true;
  let isBookmarkScreen = false;
  let showFooter = true;
  let exploredCharCount = 0;
  let bookCharCount = 0;
  let autoScroller: AutoScroller | undefined;
  let bookmarkManager: BookmarkManager | undefined;
  let pageManager: PageManager | undefined;
  let bookmarkData: Promise<BooksDbBookmarkData | undefined> = Promise.resolve(undefined);

  const autoHideHeader$ = timer(2500).pipe(
    tap(() => (showHeader = false)),
    reduceToEmptyString()
  );

  const bookId$ = iffBrowser(() => readableToObservable(page)).pipe(
    map((pageObj) => Number(pageObj.url.searchParams.get('id'))),
    shareReplay({ refCount: true, bufferSize: 1 })
  );

  const rawBookData$ = bookId$.pipe(
    switchMap((id) => database.getBookById(id)),
    share()
  );

  const leaveIfBookMissing$ = rawBookData$.pipe(
    tap((data) => {
      console.log('data', data);
      // if (!data) {
      //   goto('/manage');
      // }
    }),
    reduceToEmptyString()
  );

  const initBookmarkData$ = rawBookData$.pipe(
    tap((rawBookData: any) => {
      if (!rawBookData) return;
      bookmarkData = database.getBookmarkByBookId(rawBookData.id);
    }),
    reduceToEmptyString()
  );

  const bookData$ = rawBookData$.pipe(
    switchMap((rawBookData) => {
      if (!rawBookData) return EMPTY;

      sectionList$.next(rawBookData.sections || []);

      return loadBookData(rawBookData, '.book-content', document);
    }),
    shareReplay({ refCount: true, bufferSize: 1 })
  );

  const notifyImmersionReader$ = rawBookData$.pipe(
    tap((rawBookData: any) => {
      if (!rawBookData) return;
      if (window.flutter_inappwebview != null) {
        const bookData = { ...rawBookData, blobs: null };
        window.flutter_inappwebview?.callHandler('onLoadBook', bookData);
      }
      // console.log(
      //   JSON.stringify({
      //     bookId: rawBookData.id,
      //     title: rawBookData.title,
      //     bookCharCount: rawBookData.sections
      //       ? rawBookData.sections.reduce(
      //           (sum: number, section: Section) => sum + (section.characters || 0),
      //           0
      //         )
      //       : null,
      //     messageType: 'load-book'
      //   })
      // );
    }),
    reduceToEmptyString()
  );

  const resize$ = iffBrowser(() => fromEvent(visualViewport, 'resize')).pipe(share());

  const containerViewportWidth$ = resize$.pipe(
    startWith(0),
    map(() => visualViewport.width),
    takeWhenBrowser()
  );

  const containerViewportHeight$ = resize$.pipe(
    startWith(0),
    map(() => visualViewport.height),
    takeWhenBrowser()
  );

  const themeOption$ = theme$.pipe(
    map((theme) => availableThemes.get(theme)),
    filter((o): o is NonNullable<typeof o> => !!o)
  );

  const backgroundColor$ = themeOption$.pipe(map((o) => o.backgroundColor));

  const backgroundStyleName = 'background-color';
  const setBackgroundColor$ = backgroundColor$.pipe(
    tapDom(
      () => document.body,
      (backgroundColor, body) => body.style.setProperty(backgroundStyleName, backgroundColor),
      (body) => body.style.removeProperty(backgroundStyleName)
    ),
    reduceToEmptyString(),
    takeWhenBrowser()
  );

  const writingModeStyleName = 'writing-mode';
  const setWritingMode$ = writingMode$.pipe(
    tapDom(
      () => document.documentElement,
      (writingMode, documentElement) =>
        documentElement.style.setProperty(writingModeStyleName, writingMode),
      (documentElement) => documentElement.style.removeProperty(writingModeStyleName)
    ),
    reduceToEmptyString(),
    takeWhenBrowser()
  );

  const sectionData$ = iffBrowser(() => sectionProgress$).pipe(
    map((sectionProgress) => [...sectionProgress.values()])
  );

  $: if ($tocIsOpen$) {
    autoScroller?.off();
  }

  function onKeydown(ev: KeyboardEvent) {
    const result = onKeydownReader(
      ev,
      bookReaderKeybindMap$.getValue(),
      bookmarkPage,
      scrollToBookmark,
      (x) => multiplier$.next(multiplier$.getValue() + x),
      autoScroller,
      pageManager,
      $verticalMode$,
      changeChapter
    );

    if (!result) return;

    if (document.activeElement instanceof HTMLElement) {
      document.activeElement.blur();
    }
    ev.preventDefault();
  }

  function getBookIdSync() {
    let bookId: number | undefined;
    bookId$.subscribe((x) => (bookId = x)).unsubscribe();
    return bookId;
  }

  async function bookmarkPage() {
    const bookId = getBookIdSync();
    if (!bookId || !bookmarkManager) return;

    const data = bookmarkManager.formatBookmarkData(bookId);
    await database.setBookmark(data);
    bookmarkData = Promise.resolve(data);
  }

  async function scrollToBookmark() {
    const data = await bookmarkData;
    if (!data || !bookmarkManager) return;
    bookmarkManager.scrollToBookmark(data);
  }

  function onBookManagerClick() {
    database.deleteLastItem();
    bookmarkPage();
  }

  function immersionReaderAudioClick() {
    if (window.flutter_inappwebview != null) {
      const bookId = getBookIdSync();
      window.flutter_inappwebview?.callHandler('openAudioBookDialog', bookId);
    }
  }

  function onFullscreenClick() {
    if (!fullscreenManager.fullscreenElement) {
      fullscreenManager.requestFullscreen(document.documentElement);
      return;
    }
    fullscreenManager.exitFullscreen();
  }

  function changeChapter(offset: number) {
    if (!$sectionData$?.length) {
      return;
    }

    const [mainChapters, currentChapterIndex] = getChapterData($sectionData$);

    if (
      (!currentChapterIndex && offset === -1) ||
      (offset === 1 && currentChapterIndex === mainChapters.length - 1)
    ) {
      return;
    }

    nextChapter$.next(mainChapters[currentChapterIndex + offset].reference);
  }
</script>

<svelte:head>
  <title>{formatPageTitle($rawBookData$?.title ?? '')}</title>
</svelte:head>

{$autoHideHeader$ ?? ''}
<button class="fixed inset-x-0 top-0 z-10 h-8 w-full" on:click={() => (showHeader = true)} />
{#if showHeader}
  <div
    class="elevation-4 writing-horizontal-tb fixed inset-x-0 top-0 z-10 w-full"
    transition:fly|local={{ y: -300, easing: quintInOut }}
    use:clickOutside={() => (showHeader = false)}
  >
    <BookReaderHeader
      isDevMode={false}
      hasChapterData={!!$sectionData$?.length}
      showFullscreenButton={fullscreenManager.fullscreenEnabled}
      autoScrollMultiplier={$multiplier$}
      bind:isBookmarkScreen
      on:tocClick={() => {
        showHeader = false;
        tocIsOpen$.next(true);
      }}
      on:toDevClick={() => {
        showHeader = false;
        toDevIsOpen$.next(true);
      }}
      on:fullscreenClick={onFullscreenClick}
      on:bookmarkClick={bookmarkPage}
      on:bookManagerClick={onBookManagerClick}
      on:settingsClick={bookmarkPage}
      on:immersionReaderAudioClick={immersionReaderAudioClick}
    />
  </div>
{/if}

<!-- update page when tapping left or right edges -->
<div class="fixed top-0 left-0 z-10 h-full w-8" on:click={() => pageManager?.nextPage()} />

<div class="fixed top-0 right-0 z-10 h-full w-5" on:click={() => pageManager?.prevPage()} />

{#if $bookData$}
  <StyleSheetRenderer styleSheet={$bookData$.styleSheet} />
  <BookReader
    htmlContent={$bookData$.htmlContent}
    width={$containerViewportWidth$ ?? 0}
    height={$containerViewportHeight$ ?? 0}
    verticalMode={$verticalMode$}
    fontColor={$themeOption$?.fontColor}
    backgroundColor={$backgroundColor$}
    hintFuriganaFontColor={$themeOption$?.hintFuriganaFontColor}
    hintFuriganaShadowColor={$themeOption$?.hintFuriganaShadowColor}
    fontSize={$fontSize$}
    fontFamilyGroupOne={$fontFamilyGroupOne$}
    fontFamilyGroupTwo={$fontFamilyGroupTwo$}
    hideSpoilerImage={$hideSpoilerImage$}
    hideFurigana={$hideFurigana$}
    furiganaStyle={$furiganaStyle$}
    viewMode={$viewMode$}
    secondDimensionMaxValue={$secondDimensionMaxValue$}
    firstDimensionMargin={$firstDimensionMargin$}
    autoPositionOnResize={$autoPositionOnResize$}
    avoidPageBreak={$avoidPageBreak$}
    pageColumns={$pageColumns$}
    autoBookmark={$autoBookmark$}
    multiplier={$multiplier$}
    bind:exploredCharCount
    bind:bookCharCount
    bind:isBookmarkScreen
    bind:bookmarkData
    bind:autoScroller
    bind:bookmarkManager
    bind:pageManager
    on:bookmark={bookmarkPage}
  />
  {$initBookmarkData$ ?? ''}
  {$notifyImmersionReader$ ?? ''}
  {$setBackgroundColor$ ?? ''}
  {$setWritingMode$ ?? ''}
{:else}
  {$leaveIfBookMissing$ ?? ''}
{/if}

{#if $toDevIsOpen$}
  <div
    class="writing-horizontal-tb fixed top-0 left-0 z-[60] flex h-full w-full max-w-xl flex-col justify-between"
    style:color={$themeOption$?.fontColor}
    style:background-color={$backgroundColor$}
    in:fly|local={{ x: -100, duration: 100, easing: quintInOut }}
  >
    <DevTools htmlContent={$bookData$.htmlContent} />
    <!-- <BookToc sectionData={$sectionData$} {exploredCharCount} /> -->
  </div>
{/if}

{#if $tocIsOpen$}
  <div
    class="writing-horizontal-tb fixed top-0 left-0 z-[60] flex h-full w-full max-w-xl flex-col justify-between"
    style:color={$themeOption$?.fontColor}
    style:background-color={$backgroundColor$}
    in:fly|local={{ x: -100, duration: 100, easing: quintInOut }}
    use:clickOutside={() => tocIsOpen$.next(false)}
  >
    <BookToc sectionData={$sectionData$} {exploredCharCount} />
  </div>
{/if}

{#if showFooter && bookCharCount}
  <div
    class="writing-horizontal-tb fixed bottom-2 right-2 z-10 text-xs leading-none"
    style:color={$themeOption$?.tooltipTextFontColor}
  >
    {exploredCharCount} / {bookCharCount} ({((exploredCharCount / bookCharCount) * 100).toFixed(
      2
    )}%)
  </div>
{/if}
<button
  class="fixed inset-x-0 bottom-0 z-10 h-8 w-full cursor-pointer"
  on:click={() => (showFooter = !showFooter)}
/>

<svelte:window on:keydown={onKeydown} />
