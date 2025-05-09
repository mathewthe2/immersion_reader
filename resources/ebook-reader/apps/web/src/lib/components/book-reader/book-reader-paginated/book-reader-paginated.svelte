<script lang="ts">
  import {
    BehaviorSubject,
    combineLatest,
    debounceTime,
    distinctUntilChanged,
    fromEvent,
    map,
    skip,
    Subject,
    switchMap,
    take,
    takeUntil,
    throttleTime
  } from 'rxjs';
  import { isMobile } from '$lib/functions/utils';
  import { afterUpdate, createEventDispatcher, onDestroy, onMount } from 'svelte';
  import Fa from 'svelte-fa';
  import { swipe } from 'svelte-gestures';
  import { faBookmark, faSpinner } from '@fortawesome/free-solid-svg-icons';
  import { browser } from '$app/env';
  import { nextChapter$, tocIsOpen$ } from '$lib/components/book-reader/book-toc/book-toc';
  import HtmlRenderer from '$lib/components/html-renderer.svelte';
  import { FuriganaStyle } from '$lib/data/furigana-style';
  import { clearRange, createRange, pulseElement } from '$lib/functions/range-util';
  import type {
    BooksDbBookData,
    BooksDbBookmarkData
  } from '$lib/data/database/books-db/versions/books-db';
  import { iffBrowser } from '$lib/functions/rxjs/iff-browser';
  import { PageManagerPaginated } from './page-manager-paginated';
  import { SectionCharacterStatsCalculator } from './section-character-stats-calculator';
  import type { BookmarkManager, PageManager } from '../types';
  import { BookmarkManagerPaginated } from './bookmark-manager-paginated';
  import { getExternalTargetElement } from '$lib/functions/utils';
  import { SECTION_CHANGE } from '$lib/data/events';

  export let rawBookData: BooksDbBookData;

  export let htmlContent: string;

  export let width: number;

  export let height: number;

  export let verticalMode: boolean;

  export let fontColor: string;

  export let backgroundColor: string;

  export let hintFuriganaFontColor: string;

  export let hintFuriganaShadowColor: string;

  export let fontSize: number;

  export let fontFamilyGroupOne: string;

  export let fontFamilyGroupTwo: string;

  export let hideSpoilerImage: boolean;

  export let hideFurigana: boolean;

  export let furiganaStyle: FuriganaStyle;

  export let loadingState: boolean;

  export let bookmarkData: Promise<BooksDbBookmarkData | undefined>;

  export let pageManager: PageManager | undefined;

  export let bookmarkManager: BookmarkManager | undefined;

  export let exploredCharCount: number;

  export let bookCharCount: number;

  export let isBookmarkScreen = false;

  export let avoidPageBreak = true;

  export let pageColumns: number;

  export let firstDimensionMargin: number;

  export let autoBookmark = false;

  export let customReadingPointRange: Range | undefined;

  const dispatch = createEventDispatcher<{
    bookmark: void;
    contentChange: HTMLElement;
  }>();

  let scrollEl: HTMLElement | undefined;

  let contentEl: HTMLElement | undefined;

  let calculator: SectionCharacterStatsCalculator | undefined;

  let sections: Element[] = [];

  let concretePageManager: PageManagerPaginated | undefined;

  let concreteBookmarkManager: BookmarkManagerPaginated | undefined;

  let scrollWhenReady: boolean;

  let allowDisplay = false;

  let displayedHtml = '';

  let skipFirstHtmlLoad = true;

  let previousIntendedCount = 0;

  let exploredCharCountAdjustedToBookmark = false;

  let bookmarkTopAdjustment: string | undefined;

  let bookmarkLeftAdjustment: string | undefined;

  let bookmarkRightAdjustment: string | undefined;

  const selectionToBookmarkEnabled = true; // from store

  let useExploredCharCount = false;

  let wasResized = false;

  let currentSectionId = '';

  let isEnableSwipe = true;

  let isSentNotificationToImmersionReader = false;

  const width$ = new Subject<number>();

  const height$ = new Subject<number>();

  const sectionIndex$ = new BehaviorSubject<number>(-1);

  const pageChange$ = new Subject<boolean>();

  const virtualScrollPos$ = new BehaviorSubject(0);

  const sectionRenderComplete$ = new Subject<number>();

  const sectionReady$ = new Subject<SectionCharacterStatsCalculator>();

  const currentSection$ = sectionIndex$.pipe(map((index) => sections[index]?.innerHTML || ''));

  const cssClassOverflowHidden = 'overflow-hidden';

  const gap = 40;

  const destroy$ = new Subject<void>();

  $: bookmarkData.then((data) => {
    // useExploredCharCount = false;
    exploredCharCountAdjustedToBookmark = false;
    updateBookmarkScreen(data);
  });

  $: if (width) width$.next(width);

  $: if (height) height$.next(height);

  $: columnCount = verticalMode ? 1 : pageColumns || Math.ceil(width / 1000);

  $: {
    if (htmlContent) {
      scrollWhenReady = true;
    }
  }

  $: {
    if (browser) {
      const tempContainer = document.createElement('div');
      tempContainer.innerHTML = htmlContent;
      sections = Array.from(tempContainer.children);
      sectionIndex$.next(0);
    }
  }

  $: {
    if (contentEl && scrollEl && sections) {
      concretePageManager = new PageManagerPaginated(
        contentEl,
        scrollEl,
        sections,
        sectionIndex$,
        virtualScrollPos$,
        width,
        height,
        gap,
        verticalMode,
        pageChange$,
        sectionRenderComplete$
      );
      pageManager = concretePageManager;
    }
  }

  $: {
    if (calculator && width && height && !loadingState) {
      const c = calculator;
      requestAnimationFrame(() => {
        onContentDisplayChange(c);
      });
    }
  }

  $: {
    if (calculator && !loadingState) {
      const sectionIndex = sectionIndex$.getValue();
      const section = sections[sectionIndex];

      currentSectionId = section?.id.startsWith('ttu-') ? section.id : '';
      sectionRenderComplete$.next(sectionIndex$.getValue());
    }
  }

  $: {
    if (calculator && concretePageManager) {
      concreteBookmarkManager = new BookmarkManagerPaginated(
        calculator,
        concretePageManager,
        sectionReady$,
        sectionIndex$,
        (c) => (previousIntendedCount = c)
      );
      bookmarkManager = concreteBookmarkManager;
    }
  }

  $: if (browser) {
    // because Yomichan popup creates overflow on vertical-rl
    document.body.classList.add(cssClassOverflowHidden);
  }

  onMount(() => {
    document.addEventListener('ttu-action', handleAction, false);
  });

  async function handleAction({ detail }: any) {
    if (!detail.type || !calculator || !concretePageManager) {
      return;
    }

    if (detail.type === 'cue') {
      const targetSection = getTargetSection(detail.selector);

      if (targetSection === -1) {
        return;
      }

      const currentSection = sectionIndex$.getValue();

      if (currentSection !== targetSection) {
        const waitForSection = new Promise<void>((resolve) => {
          sectionReady$.pipe(take(1)).subscribe(() => resolve());
        });

        sectionIndex$.next(targetSection);
        concretePageManager.scrollTo(0, false);

        await waitForSection;
      }

      const scrollPos = getTargetScrollPos(calculator, detail.selector);

      if (scrollPos < 0) {
        return;
      }

      concretePageManager.scrollTo(scrollPos, true);

      if (currentSection !== targetSection) {
        document.dispatchEvent(new CustomEvent(SECTION_CHANGE));
      }
    }

    if (detail.type === 'enableSwipe') {
      isEnableSwipe = true;
    }

    if (detail.type === 'disableSwipe') {
      isEnableSwipe = false;
    }
  }

  onDestroy(() => {
    document.body.classList.remove(cssClassOverflowHidden);
    destroy$.next();
    destroy$.complete();
  });

  combineLatest([width$, height$])
    .pipe(
      skip(1),
      switchMap(() => sectionReady$.pipe(take(1))),
      takeUntil(destroy$)
    )
    .subscribe(() => {
      bookmarkData.then((data) => {
        if (!calculator || !concretePageManager) return;

        const useBookmark =
          data?.exploredCharCount &&
          isBookmarkScreen &&
          (data.exploredCharCount === exploredCharCount ||
            data.exploredCharCount === previousIntendedCount);

        const scrollPos = calculator.getScrollPosByCharCount(
          useBookmark && data.exploredCharCount === exploredCharCount
            ? data.exploredCharCount
            : previousIntendedCount
        );

        if (scrollPos < 0) return;

        wasResized = !useBookmark;
        concretePageManager.scrollTo(scrollPos, false);
      });
    });

  pageChange$.pipe(takeUntil(destroy$)).subscribe((isUser) => {
    if (!isSentNotificationToImmersionReader) {
      requestAnimationFrame(() => sendReaderReadyToImmersionReader());
    }
    if (!calculator) return;

    exploredCharCount = calculator.calcExploredCharCount(customReadingPointRange);
    if (isUser) {
      previousIntendedCount = exploredCharCount;
    }
    sendProgressToImmersionReader(exploredCharCount);
    bookmarkData.then((data) => {
      useExploredCharCount = isUser || wasResized;
      updateBookmarkScreen(data);
      wasResized = false;
    });
  });

  if (autoBookmark) {
    pageChange$.pipe(debounceTime(500), takeUntil(destroy$)).subscribe((isUser) => {
      if (isUser) {
        dispatch('bookmark');
      }
    });
  }

  function getTargetSection(selector: string) {
    let targetSection = -1;

    for (let index = 0, { length } = sections; index < length; index += 1) {
      const element = getExternalTargetElement(sections[index], selector);

      if (element) {
        targetSection = index;
        break;
      }
    }

    return targetSection;
  }

  function getTargetScrollPos(
    calculatorInstance: SectionCharacterStatsCalculator,
    selector: string
  ) {
    const targetElement = getExternalTargetElement(document, selector);
    const nodeRange = document.createRange();

    if (!targetElement) {
      return -1;
    }

    nodeRange.setStart(targetElement, 0);
    nodeRange.setEnd(targetElement, targetElement.childNodes.length);

    return calculatorInstance.getScrollPosByCharCount(
      calculatorInstance.calcExploredCharCount(nodeRange)
    );
  }

  currentSection$.pipe(distinctUntilChanged(), takeUntil(destroy$)).subscribe(() => {
    allowDisplay = false;
  });

  currentSection$.pipe(takeUntil(destroy$)).subscribe((html) => {
    const nestAnimationFrame = (fn: () => void, count: number) => {
      if (count === 0) {
        fn();
        return;
      }
      requestAnimationFrame(() => nestAnimationFrame(fn, count - 1));
    };

    // 2x for loading screen to render
    nestAnimationFrame(() => {
      displayedHtml = html;
    }, 2);
  });

  iffBrowser(() => fromEvent<WheelEvent>(document.body, 'wheel', { passive: true }))
    .pipe(throttleTime(50), takeUntil(destroy$))
    .subscribe((ev) => {
      if (!$tocIsOpen$) {
        let multiplier = (ev.deltaX < 0 ? -1 : 1) * (verticalMode ? -1 : 1);
        if (!ev.deltaX) {
          multiplier = ev.deltaY < 0 ? -1 : 1;
        }
        concretePageManager?.flipPage(multiplier as -1 | 1);
      }
    });

  function updateSectionData(updatedCustomReadingRange: Range | undefined) {
    if (!concretePageManager || !calculator) {
      return;
    }

    concretePageManager.updateSectionDataByOffset(
      calculator.getOffsetToRange(updatedCustomReadingRange, columnCount)
    );
  }

  function onHtmlLoad() {
    if (skipFirstHtmlLoad) {
      skipFirstHtmlLoad = false;
      return;
    }
    if (!scrollEl) return;

    calculator = new SectionCharacterStatsCalculator(
      scrollEl,
      sections,
      virtualScrollPos$,
      () => width,
      () => height,
      () => gap,
      verticalMode,
      scrollEl,
      document
    );
    exploredCharCount = 0;
    previousIntendedCount = 0;
    bookCharCount = calculator.charCount;

    calculator.updateCurrentSection(sectionIndex$.getValue());
    dispatch('contentChange', scrollEl);
  }

  function sendProgressToImmersionReader(exploredCharCount: number) {
    if (window.flutter_inappwebview != null) {
      window.flutter_inappwebview?.callHandler('onContentDisplayChange', exploredCharCount);
    }
  }

  function sendReaderReadyToImmersionReader() {
    if (window.flutter_inappwebview != null) {
      window.flutter_inappwebview?.callHandler('onReaderReady', {
        bookId: rawBookData.id,
        playBackPositionInMs: rawBookData.playBackPositionInMs
      });
      isSentNotificationToImmersionReader = true;
    }
  }

  function onContentDisplayChange(_calculator: SectionCharacterStatsCalculator) {
    _calculator.updateParagraphPos();
    exploredCharCount = _calculator.calcExploredCharCount(customReadingPointRange);
    sectionReady$.next(_calculator);

    if (scrollWhenReady) {
      scrollWhenReady = false;
      bookmarkData.then((data) => {
        if (!data || !bookmarkManager) return;
        exploredCharCount = data.exploredCharCount || 0;
        bookmarkManager.scrollToBookmark(data);
      });
    } else if (!wasResized) {
      bookmarkData.then(updateBookmarkScreen);
    }
    allowDisplay = true;
  }

  // function onContentDisplayChange(_calculator: SectionCharacterStatsCalculator) {
  //   _calculator.updateParagraphPos();
  //   exploredCharCount = _calculator.calcExploredCharCount();
  //   sectionReady$.next(_calculator);
  //   bookmarkData.then(updateBookmarkScreen);

  //   if (scrollWhenReady) {
  //     scrollWhenReady = false;
  //     bookmarkData.then((data) => {
  //       if (!data || !bookmarkManager) return;
  //       bookmarkManager.scrollToBookmark(data);
  //     });
  //   }
  //   allowDisplay = true;
  // }

  function updateBookmarkScreen(data: BooksDbBookmarkData | undefined) {
    const bookmarkCharCount = data?.exploredCharCount;
    if (!calculator || !bookmarkCharCount) return;

    const result = calculator.checkBookmarkOnScreen(bookmarkCharCount);

    if (scrollEl && result.isBookmarkScreen) {
      const dimentionAdjustment = Number(
        getComputedStyle(scrollEl)[verticalMode ? 'marginTop' : 'marginRight'].replace(/px$/, '')
      );

      if (!result.bookmarkPos) {
        setDefaultBookmarkPositions(dimentionAdjustment);
      } else if (verticalMode) {
        bookmarkTopAdjustment = dimentionAdjustment ? `${dimentionAdjustment}px` : '0.5rem';
        bookmarkLeftAdjustment = `${result.bookmarkPos.left}px`;
        bookmarkRightAdjustment = undefined;
      } else {
        bookmarkTopAdjustment = `${result.bookmarkPos.top}px`;
        bookmarkRightAdjustment = undefined;
        bookmarkLeftAdjustment =
          result.bookmarkPos.left > 0
            ? `calc(${result.bookmarkPos.left}px - ${isMobile ? '15' : '20'}px)`
            : `calc(${Math.max(isMobile ? 15 : 20, dimentionAdjustment)}px)`;
      }
    } else {
      setDefaultBookmarkPositions(0);
    }

    if (result.isBookmarkScreen && data.exploredCharCount) {
      if (result.node && !exploredCharCountAdjustedToBookmark && !result.isFirstNode) {
        updateSectionData(createRange(result.node));
      } else if (result.isFirstNode) {
        updateSectionData(undefined);
      }

      exploredCharCount = exploredCharCountAdjustedToBookmark
        ? exploredCharCount
        : data.exploredCharCount;
      previousIntendedCount = exploredCharCount;
      exploredCharCountAdjustedToBookmark = true;
    }

    isBookmarkScreen = result.isBookmarkScreen;
  }

  function setDefaultBookmarkPositions(dimensionAdjustment: number) {
    if (verticalMode) {
      bookmarkTopAdjustment = dimensionAdjustment ? `${dimensionAdjustment}px` : '0.5rem';
      bookmarkLeftAdjustment = firstDimensionMargin
        ? `${width - firstDimensionMargin}px`
        : undefined;
      bookmarkRightAdjustment = firstDimensionMargin ? undefined : '0.75rem';
    } else {
      bookmarkTopAdjustment = firstDimensionMargin ? `${firstDimensionMargin}px` : '0.5rem';
      bookmarkLeftAdjustment = dimensionAdjustment
        ? `calc(${dimensionAdjustment}px + 0.75rem)`
        : '0.75rem';
      bookmarkRightAdjustment = undefined;
    }
  }

  function onSwipe(ev: CustomEvent<{ direction: 'top' | 'right' | 'left' | 'bottom' }>) {
    if (!concretePageManager || $tocIsOpen$ || !isEnableSwipe) return;
    if (ev.detail.direction !== 'left' && ev.detail.direction !== 'right') return;
    const swipeLeft = ev.detail.direction === 'left';
    const nextPage = verticalMode ? !swipeLeft : swipeLeft;
    concretePageManager.flipPage(nextPage ? 1 : -1);
  }

  function onKeydown(ev: KeyboardEvent) {
    if (!concretePageManager || $tocIsOpen$) return;
    switch (ev.code) {
      case 'ArrowLeft':
        concretePageManager[verticalMode ? 'nextPage' : 'prevPage']();
        break;
      case 'ArrowRight':
        concretePageManager[verticalMode ? 'prevPage' : 'nextPage']();
        break;
      case 'ArrowUp':
        concretePageManager.prevPage();
        break;
      case 'ArrowDown':
        concretePageManager.nextPage();
        break;
      default:
    }
  }

  nextChapter$.pipe(takeUntil(destroy$)).subscribe((chapterId) => {
    const nextSectionIndex = sections.findIndex(
      (section) => section.id === chapterId || section.querySelector(`[id="${chapterId}"]`)
    );

    if (nextSectionIndex > -1) {
      sectionIndex$.next(nextSectionIndex);
      concretePageManager?.scrollTo(0, true);
    }
  });
</script>

<div
  bind:this={scrollEl}
  style:color={fontColor}
  style:font-size="{fontSize}px"
  style:padding-top={!verticalMode && firstDimensionMargin
    ? `${firstDimensionMargin}px`
    : undefined}
  style:padding-bottom={!verticalMode && firstDimensionMargin
    ? `${firstDimensionMargin}px`
    : undefined}
  style:padding-left={verticalMode && firstDimensionMargin
    ? `${firstDimensionMargin}px`
    : undefined}
  style:padding-right={verticalMode && firstDimensionMargin
    ? `${firstDimensionMargin}px`
    : undefined}
  style:max-width={width ? `${width}px` : undefined}
  style:max-height={verticalMode && height ? `${height}px` : undefined}
  style:--font-family-serif={fontFamilyGroupOne}
  style:--font-family-sans-serif={fontFamilyGroupTwo}
  style:--book-content-hint-furigana-font-color={hintFuriganaFontColor}
  style:--book-content-hint-furigana-shadow-color={hintFuriganaShadowColor}
  style:--book-content-child-width="{width}px"
  style:--book-content-child-height="{height}px"
  style:--book-content-child-column-width={!verticalMode && columnCount === 1 ? `${width}px` : ''}
  style:--book-content-column-count={columnCount}
  style:--book-content-image-max-width="{verticalMode
    ? width
    : (width + gap) / columnCount - gap}px"
  class:book-content--avoid-page-break={avoidPageBreak}
  class:book-content--writing-vertical-rl={verticalMode}
  class:book-content--writing-horizontal-rl={!verticalMode}
  class:book-content--hide-furigana={hideFurigana}
  class:book-content--hide-spoiler-image={hideSpoilerImage}
  class:book-content--furigana-style-partial={furiganaStyle === FuriganaStyle.Partial}
  class:book-content--furigana-style-full={furiganaStyle === FuriganaStyle.Full}
  class:book-content--furigana-style-toggle={furiganaStyle === FuriganaStyle.Toggle}
  class="book-content m-auto"
  use:swipe={{ timeframe: 500, minSwipeDistance: 10, touchAction: 'pan-y' }}
  on:swipe={onSwipe}
>
  <div class="book-content-container" id={currentSectionId || null} bind:this={contentEl}>
    <HtmlRenderer html={displayedHtml} on:load={onHtmlLoad} />
  </div>
</div>

{#if !allowDisplay}
  <div
    class="fixed inset-0 flex h-full w-full items-center justify-center text-7xl"
    style:color={fontColor}
    style:background-color={backgroundColor}
  >
    <Fa icon={faSpinner} spin />
  </div>
{/if}

{#if isBookmarkScreen}
  <div
    class="fixed h-3 w-3 text-base opacity-25 sm:text-xl"
    style:color={fontColor}
    style:top={bookmarkTopAdjustment}
    style:left={bookmarkLeftAdjustment}
    style:right={bookmarkRightAdjustment}
  >
    <Fa icon={faBookmark} />
  </div>
{/if}

<svelte:window on:keydown={onKeydown} />

<style lang="scss">
  @import '../styles';

  .book-content {
    overflow: hidden;
    width: var(--book-content-child-width, 95vh);
  }

  .book-content-container {
    column-count: var(--book-content-column-count, 1);
    column-width: var(
      --book-content-child-column-width,
      auto
    ); // required for WebKit + column-count 1
    column-gap: 40px;
    column-fill: auto;
    height: var(--book-content-child-height, 95vh);
  }

  .book-content {
    :global(svg),
    :global(img) {
      max-width: var(--book-content-image-max-width, 100vw);
      max-height: var(--book-content-child-height, 100vh);
    }

    &.book-content--avoid-page-break {
      :global(p) {
        break-inside: avoid;
      }
    }

    :global(.ttu-img-container) {
      // Needed for Blink rendering engine
      break-inside: avoid;
    }
  }

  .book-content--writing-vertical-rl {
    .book-content-container {
      column-width: var(--book-content-child-height, 100vh);
      width: 100%;
      height: auto;
    }
  }
</style>
