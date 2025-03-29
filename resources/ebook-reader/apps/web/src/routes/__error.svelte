<script context="module" lang="ts">
  import type { ErrorLoad } from '@sveltejs/kit';

  export const load: ErrorLoad = ({ error }) => {
    console.error('Error occurred during load:', error);
    return {
      status: 302,
      redirect: '/manage'
    };
  };
</script>
