/**
 * @license BSD-3-Clause
 * Copyright (c) 2022, ッツ Reader Authors
 * All rights reserved.
 */

import { isNotJapaneseRegex } from './get-character-count';

export function getCharacters(node: Node) {
  // gaiji?
  if (!node.textContent) return '';
  return node.textContent.replace(isNotJapaneseRegex, '');
}

export interface CharactersResult {
  characters: string;
  originalCharacters: string;
}

export function getCharactersWithOriginal(node: Node): CharactersResult {
  if (!node.textContent)
    return {
      characters: '',
      originalCharacters: ''
    };
  const characters = node.textContent.replace(isNotJapaneseRegex, '');
  return {
    characters,
    originalCharacters: node.textContent
  };
}

export function getCharactersMap(charactersResult: CharactersResult): Record<number, number> {
  const m: Record<number, number> = {};
  let j = 0;
  for (let i = 0; i < Array(...charactersResult.originalCharacters).length; i += 1) {
    while (
      Array(...charactersResult.originalCharacters)[j] !== Array(...charactersResult.characters)[i]
    ) {
      j += 1;
    }
    m[i] = j;
    j += 1;
  }
  return m;
}

const sentenceSeparators = ['。', '【', '】', '「', '」', '『', '』', '？', '！', '?', '!', '.'];

export function getContextualSentence(
  charactersData: CharactersResult,
  matchBeforeFilterIndex: number
): string {
  const target = Array(...charactersData.originalCharacters);
  let i = matchBeforeFilterIndex;
  while (i > 0 && !sentenceSeparators.includes(target[i - 1])) {
    i -= 1;
  }
  let j = matchBeforeFilterIndex;
  while (j < target.length && !sentenceSeparators.includes(target[j])) {
    j += 1;
  }
  // include extra separators at end of sentence
  while (j + 1 < target.length && sentenceSeparators.includes(target[j + 1])) {
    j += 1;
  }
  return Array.from(target)
    .slice(i, j + 1) // +1 because end exclusive
    .join('');
}
