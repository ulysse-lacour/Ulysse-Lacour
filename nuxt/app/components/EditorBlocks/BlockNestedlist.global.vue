<template>
  <ul class="richtext-ul list-inside list-disc" role="list">
    <template
      v-for="(block, idx) in blockData?.data?.items ?? []"
      :key="idx + '_' + (block?.content ?? '')"
    >
      <li role="listitem">{{ block.content }}</li>
      <template v-if="block?.items?.length">
        <ul class="richtext-ul ml-6 list-inside list-disc" role="list">
          <template
            v-for="(innerBlock, innerIdx) in block.items"
            :key="innerIdx + '_' + innerBlock.content"
          >
            <li role="listitem">{{ innerBlock.content }}</li>
          </template>
        </ul>
      </template>
    </template>
  </ul>
</template>

<script setup lang="ts">
  interface NestedListItem {
    content: string;
    items: NestedListItem[];
  }

  interface BlockData {
    data: {
      items: NestedListItem[];
    };
  }

  const props = defineProps({
    blockData: {
      type: Object as () => BlockData,
      required: true,
    },
  });
</script>
