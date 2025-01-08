<script setup lang="ts">
  import { SliderRange, SliderRoot, SliderThumb, SliderTrack } from "radix-vue";
  import { ref } from "vue";

  const sliderValue = ref([50]);
</script>

<template>
  <SliderRoot
    v-model="sliderValue"
    class="relative flex h-5 w-[200px] touch-none select-none items-center"
    :max="100"
    :step="1"
  >
    <SliderTrack class="relative h-[3px] grow rounded-full bg-blackA10">
      <SliderRange class="absolute h-full rounded-full bg-blackA10" />
    </SliderTrack>
    <SliderThumb
      class="block h-5 w-5 rounded-[10px] bg-white shadow-[0_2px_10px] shadow-blackA7 hover:bg-gray-800 focus:shadow-[0_0_0_5px] focus:shadow-blackA8 focus:outline-none"
      aria-label="Volume"
    />
  </SliderRoot>
</template>
