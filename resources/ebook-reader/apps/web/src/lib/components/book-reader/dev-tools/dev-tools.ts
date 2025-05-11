/**
 * @license BSD-3-Clause
 * Copyright (c) 2022, ッツ Reader Authors
 * All rights reserved.
 */

import { Subject } from 'rxjs';
// import { getParagraphNodes } from '../get-paragraph-nodes';
import {
  type CharactersResult,
  getCharactersMap,
  getCharactersWithOriginal,
  getContextualSentence
} from '$lib/functions/get-characters';
import { type SectionWithProgress } from '$lib/components/book-reader/book-toc/book-toc';
import { getParagraphNodes } from '../get-paragraph-nodes';
import { countUnicodeCharacters } from '$lib/functions/get-character-count';

export const toDevIsOpen$ = new Subject<boolean>();

interface SearchResult {
  chapter: string;
  characterCount: number;
  characterIndex: number;
  characterLength: number;
  sentence: string;
}

function codeUnitIndexToCodePointIndex(str: string, cuIndex: number) {
  let count = 0;
  for (let i = 0; i < cuIndex; ) {
    const code = str.codePointAt(i) ?? 0;
    const charLen = code > 0xffff ? 2 : 1;
    i += charLen;
    count += 1;
  }
  return count;
}

export function searchInBook(
  htmlContent: string,
  sectionData: SectionWithProgress[],
  searchKeyword: string
) {
  const tempContainer = document.createElement('div');
  tempContainer.innerHTML = htmlContent;
  const sections = Array.from(tempContainer.children);
  let previousMainChapter: SectionWithProgress | null = null;
  let previousCharacterCount = 0;
  let charactersList: CharactersResult[] = [];
  const totalMatches: SearchResult[] = [];
  const keywordLength = Array(...searchKeyword).length;
  sections.forEach((section, index) => {
    const paragraphs = getParagraphNodes(section);
    let isMergeWithPreviousNode = false;
    paragraphs.forEach((paragraph) => {
      const charactersWithOriginal = getCharactersWithOriginal(paragraph);
      if (isMergeWithPreviousNode) {
        // merge with previous node if previous node is not furigana or end of paragraph
        charactersList[charactersList.length - 1] = {
          characters:
            charactersList[charactersList.length - 1].characters +
            charactersWithOriginal.characters,
          originalCharacters:
            charactersList[charactersList.length - 1].originalCharacters +
            charactersWithOriginal.originalCharacters,
          isMergeWithNext: charactersWithOriginal.isMergeWithNext
        };
      } else {
        charactersList.push(charactersWithOriginal);
      }
      isMergeWithPreviousNode = charactersWithOriginal.isMergeWithNext;
    });

    if (sectionData[index].parentChapter == null) {
      if (previousMainChapter != null) {
        charactersList.forEach((charactersData) => {
          const matches = [
            ...charactersData.characters.matchAll(new RegExp(searchKeyword, 'gi'))
          ].map((a) => codeUnitIndexToCodePointIndex(charactersData.characters, a.index));
          if (matches.length > 0) {
            const charactersMap = getCharactersMap(charactersData);
            const matchesAdjusted = matches.map((match) => match + previousCharacterCount);
            const matchesBeforeFilter = matches.map((match) => charactersMap[match]);
            const sentences = matchesBeforeFilter.map((match) =>
              getContextualSentence(charactersData, match)
            );
            matchesAdjusted.forEach((matchAdjusted, matchIndex) => {
              if (matchesAdjusted.length > 0) {
                totalMatches.push({
                  chapter: previousMainChapter?.label ?? '',
                  characterCount: matchAdjusted,
                  sentence: sentences[matchIndex],
                  characterIndex: matchesBeforeFilter[matchIndex],
                  characterLength: keywordLength
                });
              }
            });
          }
          previousCharacterCount += countUnicodeCharacters(charactersData.characters);
        });
      }
      charactersList = [];
      previousMainChapter = sectionData[index];
    }
  });
  // console.log('hello');
  return totalMatches;
}

export function getTTUParent(node: Node) {
  return node.parentElement!.closest('div[id^="ttu-"]');
}

export function getTextNode(node: Node | null): Node | undefined {
  if (node === null) {
    return undefined;
  }

  if (node.nodeType === Node.TEXT_NODE && normalizeString(node.textContent)) {
    return node;
  }

  let textNode: Node | undefined;

  for (let index = 0, { length } = node.childNodes; index < length; index += 1) {
    const childNode = node.childNodes[index];

    if (childNode.nodeType === Node.TEXT_NODE && normalizeString(node.textContent)) {
      textNode = childNode;
    } else {
      textNode = getTextNode(childNode);
    }

    if (textNode) {
      break;
    }
  }

  return textNode;
}

function normalizeString(value: string | null, toLowerCase = false) {
  const cleanValue = (value || '').replace(/\s/g, '').trim();

  return toLowerCase ? cleanValue.toLowerCase() : cleanValue;
}
