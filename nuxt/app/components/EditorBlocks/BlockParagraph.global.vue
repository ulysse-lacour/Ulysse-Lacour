<template>
  <p v-if="blockData?.data?.text" v-dompurify-html="blockData?.data?.text"></p>
</template>

<script setup lang="ts">
  interface BlockData {
    data: {
      text: string;
    };
  }

  const props = defineProps({
    blockData: {
      type: Object as PropType<BlockData>,
      required: true,
      validator: (value: BlockData) => {
        return typeof value?.data?.text === "string";
      },
    },
  });
</script>

<style scoped>
  p {
    margin-bottom: var(--fs-s);
  }
</style>
