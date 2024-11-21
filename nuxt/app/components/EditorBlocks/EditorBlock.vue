<template>
  <template v-for="block in blocks" :key="block.id">
    <component
      :is="formatBlockType(block.type)"
      v-if="block.data && formatBlockType(block.type)"
      :block-data="block"
    />
  </template>
</template>

<script setup lang="ts">
  const props = defineProps({
    blocks: {
      type: Array as PropType<any[]>,
      required: true,
    },
  });

  const formatBlockType = (str: string): string => {
    if (!str) return "";
    return "Block" + str.charAt(0).toUpperCase() + str.slice(1);
  };
</script>

<style scoped></style>
