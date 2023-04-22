<script lang="ts">
  import Ripple from '$lib/components/ripple.svelte';
  import type { ToggleOption } from './toggle-option';

  export let optionKey: string;

  export let options: ToggleOption<any>[];

  export let selectedOptionId: any;

  function mapToStyleString(style: Record<string, any> | undefined) {
    if (!style) return '';

    return Object.entries(style)
      .map(([key, value]) => `${key}: ${value}`)
      .join(';');
  }

  function notifyImmersionReaderOfSettingsUpdate(option: ToggleOption<any>) {
    console.log(
      JSON.stringify({
        optionKey: optionKey,
        optionValue: option.id,
        messageType: 'settings-change'
      })
    );
  }
</script>

<div class="-m-1">
  {#each options as option}
    <button
      class="m-1 rounded-md border border-gray-400 bg-white p-2 text-lg"
      class:border-blue-300={option.id === selectedOptionId}
      style={mapToStyleString(option.style)}
      on:click={() => {
        selectedOptionId = option.id;
        notifyImmersionReaderOfSettingsUpdate(option);
      }}
    >
      {option.text}
      <Ripple />
    </button>
  {/each}
</div>
