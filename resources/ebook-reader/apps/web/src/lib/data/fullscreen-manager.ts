/**
 * @license BSD-3-Clause
 * Copyright (c) 2022, ッツ Reader Authors
 * All rights reserved.
 */

import { browser } from '$app/env';

class FullscreenManager {
  get fullscreenEnabled() {
    // return this.fallbackSpec('fullscreenEnabled', 'webkitFullscreenEnabled') ?? false;
    return false; // this is controlled by flutter app
  }

  get fullscreenElement() {
    return this.fallbackSpec('fullscreenElement', 'webkitFullscreenElement') ?? null;
  }

  constructor(private document: Document) {}

  // eslint-disable-next-line class-methods-use-this
  async requestFullscreen(el: Element, fullscreenOptions?: FullscreenOptions) {
    const fn = fallbackSpec(el)('requestFullscreen', 'webkitRequestFullscreen');
    if (!fn) return;
    await fn(fullscreenOptions);
  }

  async exitFullscreen() {
    const fn = this.fallbackSpec('exitFullscreen', 'webkitExitFullscreen');
    if (!fn) return;
    await fn();
  }

  private fallbackSpec = fallbackSpec(this.document);
}

function fallbackSpec<T>(obj: T) {
  return <P extends keyof T>(specName: P, alias: string) =>
    tryGet(obj, specName) ?? tryGet(obj, alias as P);
}

function tryGet<T, P extends keyof T>(obj: T, propertyName: P) {
  const val = obj[propertyName];
  if (typeof val === 'function') {
    return val.bind(obj) as typeof val;
  }
  return val;
}

export const fullscreenManager = new FullscreenManager(browser ? document : ({} as Document));
