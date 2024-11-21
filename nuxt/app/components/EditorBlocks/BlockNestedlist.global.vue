<template>
  <ul class="richtext-ul list-inside list-disc">
    <template v-for="(block, idx) in blockData?.data?.items" :key="idx + '_' + block.content">
      <li>{{ block.content }}</li>

      <template v-if="block.items.length">
        <ul class="richtext-ul ml-6 list-inside list-disc">
          <template
            v-for="(innerBlock, innerIdx) in block.items"
            :key="innerIdx + '_' + innerBlock.content"
          >
            <li>{{ innerBlock.content }}</li>
          </template>
        </ul>
      </template>
    </template>
  </ul>
</template>

<script setup lang="ts">
  const props = defineProps({
    blockData: {
      type: Object,
      required: true,
    },
  });
</script>
