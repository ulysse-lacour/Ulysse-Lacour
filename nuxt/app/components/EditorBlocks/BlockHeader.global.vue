<!-- Server side issue -->
<!-- <component :is="'h' + blockData.data.level" v-dompurify-html="blockContent"></component> -->

<template>
  <template v-if="blockData.data.level === 1">
    <h1 v-if="blockData?.data?.text" v-dompurify-html="blockData?.data?.text"></h1>
  </template>
  <template v-else-if="blockData.data.level === 2">
    <h2 v-if="blockData?.data?.text" v-dompurify-html="blockData?.data?.text"></h2>
  </template>
  <template v-else-if="blockData.data.level === 3">
    <h3 v-if="blockData?.data?.text" v-dompurify-html="blockData?.data?.text"></h3>
  </template>
  <template v-else-if="blockData.data.level === 4">
    <h4 v-if="blockData?.data?.text" v-dompurify-html="blockData?.data?.text"></h4>
  </template>
  <template v-else-if="blockData.data.level === 5">
    <h5 v-if="blockData?.data?.text" v-dompurify-html="blockData?.data?.text"></h5>
  </template>
  <template v-else-if="blockData.data.level === 6">
    <h6 v-if="blockData?.data?.text" v-dompurify-html="blockData?.data?.text"></h6>
  </template>
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
  h1,
  h2,
  h3,
  h4,
  h5,
  h6 {
    margin-bottom: var(--fs-s);
  }
</style>
