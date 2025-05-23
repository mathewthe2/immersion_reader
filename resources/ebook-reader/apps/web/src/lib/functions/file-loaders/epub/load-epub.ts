/**
 * @license BSD-3-Clause
 * Copyright (c) 2022, ッツ Reader Authors
 * All rights reserved.
 */

import type { LoadData } from '../types';
import extractEpub from './extract-epub';
import generateEpubHtml from './generate-epub-html';
import generateEpubStyleSheet from './generate-epub-style-sheet';
import getEpubCoverImageFilename from './get-epub-cover-image-filename';
import reduceObjToBlobs from '../utils/reduce-obj-to-blobs';

export default async function loadEpub(file: File, document: Document): Promise<LoadData> {
  const { contents, result: data, contentsDirectory } = await extractEpub(file);
  const result = generateEpubHtml(data, contents, document, contentsDirectory);

  const displayData = {
    title: file.name,
    hasThumb: true,
    styleSheet: generateEpubStyleSheet(data, contents)
  };

  const { metadata } = contents.package;
  if (metadata) {
    const dcTitle = metadata['dc:title'];
    if (typeof dcTitle === 'string') {
      displayData.title = dcTitle;
    } else if (dcTitle && dcTitle['#text']) {
      displayData.title = dcTitle['#text'];
    }
  }
  const blobData = reduceObjToBlobs(data);
  const coverImageFilename = getEpubCoverImageFilename(contents);
  let coverImage: Blob | undefined;

  if (coverImageFilename) {
    coverImage = blobData[coverImageFilename];
  }

  return {
    ...displayData,
    elementHtml: result.element.innerHTML,
    blobs: blobData,
    coverImage,
    sections: result.sections
  };
}
