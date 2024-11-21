<template>
  <button id="burger" class="hamburger hamburger--collapse" type="button" @click="clicked">
    <span class="hamburger-box">
      <span class="hamburger-inner"></span>
    </span>
  </button>
</template>

<script setup lang="ts">
  // Events/Emit
  const emit = defineEmits(["clicked"]);

  const clicked = (event: any) => {
    const burger = document.getElementById("burger");
    if (burger) {
      burger.classList.toggle("is-active");
      emit("clicked", event);
    }
  };
</script>
