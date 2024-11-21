<template>
  <p v-if="blockData?.data?.text" v-dompurify-html="blockData?.data?.text"></p>
</template>

<script setup lang="ts">
  const props = defineProps({
    blockData: {
      type: Object,
      required: true,
    },
  });
</script>

<style scoped>
  p {
    margin-bottom: var(--fs-s);
  }
</style>
