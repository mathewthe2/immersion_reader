/**
 * @license BSD-3-Clause
 * Copyright (c) 2022, ッツ Reader Authors
 * All rights reserved.
 */

import { type SectionWithProgress } from '$lib/components/book-reader/book-toc/book-toc';
import { getParagraphNodes } from '$lib/components/book-reader/get-paragraph-nodes';
import { countUnicodeCharacters } from '../get-character-count';
import {
  type CharactersResult,
  getCharactersMap,
  getCharactersWithOriginal,
  getCroppedSentence
} from '../get-characters';

export interface SearchResult {
  chapter: string;
  characterCount: number;
  characterIndex: number;
  characterLength: number;
  sentence: string;
  paragraphIndex: number;
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
  sections.forEach((section, sectionIndex) => {
    const paragraphs = getParagraphNodes(section);
    let isMergeWithPreviousNode = false;
    paragraphs.forEach((paragraph, paragraphIndex) => {
      const charactersWithOriginal = getCharactersWithOriginal(paragraph, paragraphIndex);
      if (isMergeWithPreviousNode) {
        // merge with previous node if previous node is not furigana or end of paragraph
        charactersList[charactersList.length - 1] = {
          characters:
            charactersList[charactersList.length - 1].characters +
            charactersWithOriginal.characters,
          originalCharacters:
            charactersList[charactersList.length - 1].originalCharacters +
            charactersWithOriginal.originalCharacters,
          isMergeWithNext: charactersWithOriginal.isMergeWithNext,
          paragraphIndex: charactersList[charactersList.length - 1].paragraphIndex
        };

      } else {
        charactersList.push(charactersWithOriginal);
      }
      isMergeWithPreviousNode = charactersWithOriginal.isMergeWithNext;
    });

    if (sectionData[sectionIndex].parentChapter == null) {
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
              getCroppedSentence(charactersData, match)
            );
            matchesAdjusted.forEach((matchAdjusted, matchIndex) => {
              totalMatches.push({
                chapter: previousMainChapter?.label ?? '',
                characterCount: matchAdjusted,
                sentence: sentences[matchIndex],
                characterIndex: matchesBeforeFilter[matchIndex],
                characterLength: keywordLength,
                paragraphIndex: charactersData.paragraphIndex
              });
            });
          }
          previousCharacterCount += countUnicodeCharacters(charactersData.characters);
        });
      }
      charactersList = [];
      previousMainChapter = sectionData[sectionIndex];
    }
  });
  return totalMatches;
}

function codeUnitIndexToCodePointIndex(str: string, cuIndex: number) {
  let count = 0;
  for (let i = 0; i < cuIndex;) {
    const code = str.codePointAt(i) ?? 0;
    const charLen = code > 0xffff ? 2 : 1;
    i += charLen;
    count += 1;
  }
  return count;
}
