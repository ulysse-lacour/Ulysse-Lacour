<script setup lang="ts">
  const error = useError();

  console.error(error.value);

  const errorCode = !error.value ? 500 : error.value.statusCode;

  // const errorMessage = !error.value ? 'Something went wrong' : error.value.statusMessage;

  const handleError = () => {
    clearError({ redirect: "/" });
  };
</script>

<template>
  <NuxtLayout>
    <!-- 404 page -->
    <div v-if="errorCode === 404" id="error-page" class="error-404">
      <p class="text-2xl font-bold">{{ $t("error.error_404") }}</p>
      <div class="error-code">
        <h1>404</h1>
      </div>

      <a class="font-bold" @click="handleError"> Home </a>
    </div>

    <!-- 503 page -->
    <div v-else id="error-page" class="error-503">
      <p class="text-2xl font-bold">{{ $t("error.error_503") }}</p>
      <div class="error-code">
        <h1>503</h1>
      </div>

      <a class="font-bold" @click="handleError"> Home </a>
    </div>
  </NuxtLayout>
</template>

<style lang="scss">
  body:has(#error-page) #burger {
    display: none !important;
  }
</style>
