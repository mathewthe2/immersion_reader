<script lang="ts">
  import Fa from 'svelte-fa';
  import { getTextNode, getTTUParent, toDevIsOpen$ } from './dev-tools';
  import { faXmark } from '@fortawesome/free-solid-svg-icons';
  import { test } from '$lib/functions/audio-book/test';
  import { createEventDispatcher } from 'svelte';
  import { xlink_attr } from 'svelte/internal';
  import { type SectionWithProgress } from '$lib/components/book-reader/book-toc/book-toc';
  import { searchInBook } from '$lib/functions/immersion-reader/search-in-book';

  export let showMenu: boolean = true;
  export let htmlContent: string;
  export let sectionData: SectionWithProgress[] = [];

  // const dispatch = createEventDispatcher<{ selectHint: void; hintSelected: void }>();

  let startHintNodeContent: string | undefined;
  let startHintParentId: string | undefined;

  // $: hasHint = startHintNodeContent !== undefined && startHintParentId !== undefined;

  async function onTriggerSelectStartHint() {
    startHintNodeContent = 'abc';
    await new Promise((r) => setTimeout(r, 300)); // prevent initial click
    document.addEventListener('click', onSelectHintElement, {
      once: true,
      capture: false
    });
    // dispatch('selectHint');
    showMenu = false;
  }

  // function onResetHint() {
  //   startHintNodeContent = undefined;
  //   startHintParentId = undefined;
  // }

  function onSelectHintElement({ x, y }: MouseEvent | PointerEvent) {
    const firstTextNode = getTextNode(document.elementFromPoint(x, y));

    console.log('startHintNodeContent', startHintNodeContent);

    if (firstTextNode) {
      const ttuParent = getTTUParent(firstTextNode);

      if (ttuParent?.id) {
        startHintNodeContent = firstTextNode.textContent!;
        console.log('startHintNodeContent', startHintNodeContent);
        startHintParentId = ttuParent.id;

        firstTextNode.parentElement!.style.visibility = 'hidden';

        setTimeout(() => (firstTextNode.parentElement!.style.visibility = ''), 500);
      }
    }

    console.log('startHintNodeContent', startHintNodeContent);
    console.log('startHintParentId', startHintParentId);

    // dispatch('hintSelected');
  }

  const testSubtitle = async () => {
    if (htmlContent != null) {
      await test({ htmlContent, startHintNodeContent, startHintParentId });
    }
  };
</script>

<div class="flex justify-between p-4">
  <div>Developer Tools</div>
  <div class="cursor-pointer" on:click={() => toDevIsOpen$.next(false)}>
    <Fa icon={faXmark} />
  </div>
</div>

<div class="flex-1 overflow-auto p-4" />

<div class="flex-1 overflow-auto p-4">
  <button on:click={() => console.log(searchInBook(htmlContent, sectionData, '試験'))}
    >Search in book</button
  >
</div>

<div class="flex-1 overflow-auto p-4">
  <button on:click={() => onTriggerSelectStartHint()}>Select Element</button>
</div>

<div class="flex-1 overflow-auto p-4">
  <button on:click={() => testSubtitle()}>Run subtitle</button>
</div>

<p>
  {startHintNodeContent}
</p>
