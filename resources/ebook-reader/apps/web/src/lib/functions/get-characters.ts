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
  isMergeWithNext: boolean;
  paragraphIndex: number;
}

export function getCharactersWithOriginal(node: Node, paragraphIndex: number): CharactersResult {
  if (!node.textContent)
    return {
      characters: '',
      originalCharacters: '',
      isMergeWithNext: false,
      paragraphIndex,
    };

  const characters = node.textContent.replace(isNotJapaneseRegex, '');
  let isMergeWithNext = false;
  if (node.nodeName === 'P') {
    isMergeWithNext = node.nextSibling != null;
  } else {
    if (node.parentElement?.textContent != null) {
      isMergeWithNext = node.nextSibling?.nodeName === 'RB' ||
        node.nextSibling?.nodeName === 'RUBY' ||
        node.nextSibling?.nodeName === 'RT' ||
        node.nextSibling?.nodeName === 'SPAN' ||
        node.parentElement?.nodeName === 'RB' ||
        node.parentElement?.nextElementSibling?.nodeName === 'RUBY' ||
        node.parentElement?.nextElementSibling?.nodeName === "RT";
    }
  }
  return {
    characters,
    originalCharacters: node.textContent,
    isMergeWithNext,
    paragraphIndex,
  };
}

export function getCharactersMap(charactersResult: CharactersResult): Record<number, number> {
  const original = Array.from(charactersResult.originalCharacters);
  const chars = Array.from(charactersResult.characters);

  const m: Record<number, number> = {};
  let j = 0;

  for (let i = 0; i < chars.length; i++) {
    const char = chars[i];

    while (original[j] !== char) {
      j++;
      if (j >= original.length) {
        throw new Error(`Character "${char}" not found in originalCharacters`);
      }
    }

    m[i] = j;
    j++;
  }

  return m;
}

const sentenceSeparators = ['。', '【', '】', '「', '」', '『', '』', '？', '！', '?', '!', '.'];

export function getCroppedSentence(
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
