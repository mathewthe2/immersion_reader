/**
 * @license BSD-3-Clause
 * Copyright (c) 2022, ッツ Reader Authors
 * All rights reserved.
 */

import { Subject } from 'rxjs';

export const toDevIsOpen$ = new Subject<boolean>();

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
