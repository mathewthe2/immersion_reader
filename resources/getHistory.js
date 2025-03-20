// https://github.com/lrorpilla/jidoujisho/blob/e445b09ea8fa5df2bfae8a0d405aa1ba5fc32767/yuuna/lib/src/media/sources/reader_ttu_source.dart
/// Used to fetch JSON for all books in IndexedDB.
var bookmarkJson = JSON.stringify([]);
var dataJson = JSON.stringify([]);
var lastItemJson = JSON.stringify([]);
var blobToBase64 = function (blob) {
  return new Promise(resolve => {
    let reader = new FileReader();
    reader.onload = function () {
      let dataUrl = reader.result;
      resolve(dataUrl);
    };
    reader.readAsDataURL(blob);
  });
}
function getAllFromIDBStore(storeName) {
  return new Promise(
    function (resolve, reject) {
      var dbRequest = indexedDB.open("books");
      dbRequest.onerror = function (event) {
        reject(Error("Error opening DB"));
      };
      dbRequest.onupgradeneeded = function (event) {
        reject(Error('Not found'));
      };
      dbRequest.onsuccess = function (event) {
        var database = event.target.result;
        try {
          var transaction = database.transaction([storeName], 'readwrite');
          var objectStore;
          try {
            objectStore = transaction.objectStore(storeName);
          } catch (e) {
            reject(Error('Error getting objects'));
          }
          var objectRequest = objectStore.getAll();
          objectRequest.onerror = function (event) {
            reject(Error('Error getting objects'));
          };
          objectRequest.onsuccess = function (event) {
            if (objectRequest.result) resolve(objectRequest.result);
            else reject(Error('Objects not found'));
          };
        } catch (e) {
          reject(Error('Error getting objects'));
        }
      };
    }
  );
}
async function getTtuData() {
  try {
    items = await getAllFromIDBStore("data");
    await Promise.all(items.map(async (item) => {
      try {
        item["coverImage"] = await blobToBase64(item["coverImage"]);
        const blobKeys = Object.keys(item["blobs"]);
        await Promise.all(blobKeys.map(async (key) => {
          item["blobs"][key] = await blobToBase64(item["blobs"][key]);
        }));
      } catch (e) { }
    }));

    dataJson = JSON.stringify(items);
  } catch (e) {
    dataJson = JSON.stringify([]);
  }
  try {
    bookmarkJson = JSON.stringify(await getAllFromIDBStore("bookmark"));
  } catch (e) {
    bookmarkJson = JSON.stringify([]);
  }

  try {
    lastItemJson = JSON.stringify(await getAllFromIDBStore("lastItem"));
  } catch (e) {
    lastItemJson = JSON.stringify([]);
  }
  console.log(JSON.stringify({ messageType: "history", lastItem: lastItemJson, bookmark: bookmarkJson, data: dataJson }));
}
try {
  getTtuData();
} catch (e) {
  console.log(JSON.stringify({ messageType: "history", lastItem: lastItemJson, bookmark: bookmarkJson, data: dataJson }));
}