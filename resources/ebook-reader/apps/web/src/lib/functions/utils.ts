/**
 * @license BSD-3-Clause
 * Copyright (c) 2022, ッツ Reader Authors
 * All rights reserved.
 */

import { writableSubject } from '$lib/functions/svelte/store';

export function isMobile(window: Window) {
  if (('maxTouchPoints' in window.navigator) as any) {
    return window.navigator.maxTouchPoints > 0;
  }

  if (('msMaxTouchPoints' in window.navigator) as any) {
    return window.navigator.msMaxTouchPoints > 0;
  }

  const mQ = window.matchMedia?.('(pointer:coarse)');
  if (mQ?.media === '(pointer: coarse)') {
    return !!mQ.matches;
  }

  if ('orientation' in window) {
    return true;
  }

  const UA = window.navigator.userAgent;
  const userAgentRegex = /\b(BlackBerry|webOS|iPhone|IEMobile|Android|Windows Phone|iPad|iPod)\b/i;
  return userAgentRegex.test(UA);
}

export const isMobile$ = writableSubject<boolean>(false);
