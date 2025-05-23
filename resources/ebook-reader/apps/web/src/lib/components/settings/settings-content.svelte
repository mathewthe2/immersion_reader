<script lang="ts">
  import ButtonToggleGroup from '$lib/components/button-toggle-group/button-toggle-group.svelte';
  import type { ToggleOption } from '$lib/components/button-toggle-group/toggle-option';
  import { inputClasses } from '$lib/css-classes';
  import { availableThemes as availableThemesMap } from '$lib/data/theme-option';
  import { FuriganaStyle } from '$lib/data/furigana-style';
  import { ViewMode } from '$lib/data/view-mode';
  import type { WritingMode } from '$lib/data/writing-mode';
  import SettingsDimensionPopover from './settings-dimension-popover.svelte';
  import SettingsItemGroup from './settings-item-group.svelte';

  export let selectedTheme: string;

  export let fontSize: number;

  export let fontFamilyGroupOne: string;

  export let fontFamilyGroupTwo: string;

  export let blurImage: boolean;

  export let hideFurigana: boolean;

  export let furiganaStyle: FuriganaStyle;

  export let writingMode: WritingMode;

  export let viewMode: ViewMode;

  export let secondDimensionMaxValue: number;

  export let firstDimensionMargin: number;

  export let autoPositionOnResize: boolean;

  export let avoidPageBreak: boolean;

  export let pageColumns: number;

  export let persistentStorage: boolean;

  export let autoBookmark: boolean;

  const availableThemes = Array.from(availableThemesMap.entries()).map(([theme, option]) => ({
    theme,
    option
  }));

  const optionsForTheme: ToggleOption<string>[] = availableThemes.map(({ theme, option }) => ({
    id: theme,
    text: 'ぁあ',
    style: {
      color: option.fontColor,
      'background-color': option.backgroundColor
    }
  }));

  const optionsForToggle: ToggleOption<boolean>[] = [
    {
      id: false,
      text: 'Off'
    },
    {
      id: true,
      text: 'On'
    }
  ];

  const optionsForFuriganaStyle: ToggleOption<FuriganaStyle>[] = [
    {
      id: FuriganaStyle.Partial,
      text: 'Partial'
    },
    {
      id: FuriganaStyle.Full,
      text: 'Full'
    },
    {
      id: FuriganaStyle.Toggle,
      text: 'Toggle'
    }
  ];

  const optionsForWritingMode: ToggleOption<WritingMode>[] = [
    {
      id: 'horizontal-tb',
      text: 'Horizontal'
    },
    {
      id: 'vertical-rl',
      text: 'Vertical'
    }
  ];

  const optionsForViewMode: ToggleOption<ViewMode>[] = [
    // {
    //   id: ViewMode.Continuous,
    //   text: 'Continuous'
    // },
    {
      id: ViewMode.Paginated,
      text: 'Paginated'
    }
  ];

  let furiganaStyleTooltip = '';

  $: verticalMode = writingMode === 'vertical-rl';
  $: switch (furiganaStyle) {
    case FuriganaStyle.Full:
      furiganaStyleTooltip = 'Hidden by default, show on hover or click';
      break;
    case FuriganaStyle.Toggle:
      furiganaStyleTooltip = 'Hidden by default, can be toggled on click';
      break;
    default:
      furiganaStyleTooltip = 'Display furigana as grayed out text';
      break;
  }
  $: avoidPageBreakTooltip = avoidPageBreak
    ? 'Avoids breaking words/sentences into different pages'
    : 'Allow words/sentences to break into different pages';
</script>

<div class="grid grid-cols-1 items-center sm:grid-cols-2 sm:gap-6 lg:grid-cols-3 lg:md:gap-8">
  <div class="sm:col-span-2 lg:col-span-3">
    <SettingsItemGroup title="Theme">
      <ButtonToggleGroup
        optionKey="selectedTheme"
        options={optionsForTheme}
        bind:selectedOptionId={selectedTheme}
      />
    </SettingsItemGroup>
  </div>
  <SettingsItemGroup title="Font size">
    <input type="number" class={inputClasses} step="1" min="1" bind:value={fontSize} />
  </SettingsItemGroup>
  <SettingsItemGroup title="Font family (Group 1)">
    <input
      type="text"
      class={inputClasses}
      placeholder="Noto Serif JP"
      bind:value={fontFamilyGroupOne}
    />
  </SettingsItemGroup>
  <SettingsItemGroup title="Font family (Group 2)">
    <input
      type="text"
      class={inputClasses}
      placeholder="Noto Sans JP"
      bind:value={fontFamilyGroupTwo}
    />
  </SettingsItemGroup>
  <SettingsItemGroup title={verticalMode ? 'Reader Left/right margin' : 'Reader Top/bottom margin'}>
    <SettingsDimensionPopover
      slot="header"
      isFirstDimension
      isVertical={verticalMode}
      bind:dimensionValue={firstDimensionMargin}
    />
    <input type="number" class={inputClasses} step="1" min="0" bind:value={firstDimensionMargin} />
  </SettingsItemGroup>
  <SettingsItemGroup title={verticalMode ? 'Reader Max height' : 'Reader Max width'}>
    <SettingsDimensionPopover
      slot="header"
      isVertical={verticalMode}
      bind:dimensionValue={secondDimensionMaxValue}
    />
    <input
      type="number"
      class={inputClasses}
      step="1"
      min="0"
      bind:value={secondDimensionMaxValue}
    />
  </SettingsItemGroup>
  <SettingsItemGroup title="View mode">
    <ButtonToggleGroup
      optionKey="viewMode"
      options={optionsForViewMode}
      bind:selectedOptionId={viewMode}
    />
  </SettingsItemGroup>
  <SettingsItemGroup title="Writing mode">
    <ButtonToggleGroup
      optionKey="writingMode"
      options={optionsForWritingMode}
      bind:selectedOptionId={writingMode}
    />
  </SettingsItemGroup>
  <SettingsItemGroup
    title="Auto Bookmark"
    tooltip={'Set a bookmark after 500ms without scrolling/page change'}
  >
    <ButtonToggleGroup
      optionKey="autoBookmark"
      options={optionsForToggle}
      bind:selectedOptionId={autoBookmark}
    />
  </SettingsItemGroup>
  <SettingsItemGroup title="Blur image">
    <ButtonToggleGroup
      optionKey="blurImage"
      options={optionsForToggle}
      bind:selectedOptionId={blurImage}
    />
  </SettingsItemGroup>
  <SettingsItemGroup title="Hide furigana">
    <ButtonToggleGroup
      optionKey="hideFurigana"
      options={optionsForToggle}
      bind:selectedOptionId={hideFurigana}
    />
  </SettingsItemGroup>
  <SettingsItemGroup title="Hide furigana style" tooltip={furiganaStyleTooltip}>
    <ButtonToggleGroup
      optionKey="furiganaStyle"
      options={optionsForFuriganaStyle}
      bind:selectedOptionId={furiganaStyle}
    />
  </SettingsItemGroup>
  <SettingsItemGroup title="Persistent storage">
    <ButtonToggleGroup
      optionKey="persistentStorage"
      options={optionsForToggle}
      bind:selectedOptionId={persistentStorage}
    />
  </SettingsItemGroup>
  {#if viewMode === ViewMode.Continuous}
    <SettingsItemGroup title="Auto position on resize">
      <ButtonToggleGroup
        optionKey="autoPositionOnResize"
        options={optionsForToggle}
        bind:selectedOptionId={autoPositionOnResize}
      />
    </SettingsItemGroup>
  {:else}
    <SettingsItemGroup title="Avoid Page Break" tooltip={avoidPageBreakTooltip}>
      <ButtonToggleGroup
        optionKey="avoidPageBreak"
        options={optionsForToggle}
        bind:selectedOptionId={avoidPageBreak}
      />
    </SettingsItemGroup>
    {#if !verticalMode}
      <SettingsItemGroup title="Page Columns">
        <input type="number" class={inputClasses} step="1" min="0" bind:value={pageColumns} />
      </SettingsItemGroup>
    {/if}
  {/if}
</div>
