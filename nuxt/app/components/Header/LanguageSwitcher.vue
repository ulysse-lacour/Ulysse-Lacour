<script setup lang="ts">
  const { locale: currentLocale, locales, setLocale, t } = useI18n();

  const localeSwicth = (localeCode: "en" | "de") => {
    setLocale(localeCode);
    // // Refresh page until this is fix
    // // https://github.com/harlan-zw/nuxt-seo/issues/283
    // window.location.reload();
  };
</script>

<template>
  <div class="locale-switcher">
    <button
      v-for="locale in locales"
      :key="locale.code"
      :class="{ active: locale.code === currentLocale }"
      @click="localeSwicth(locale.code)"
    >
      {{ locale.code }}
    </button>
  </div>
</template>
