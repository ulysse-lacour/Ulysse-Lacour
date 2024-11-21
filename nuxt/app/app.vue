<template>
  <div class="app">
    <Html :lang="head.htmlAttrs!.lang" :dir="head.htmlAttrs!.dir">
      <Head>
        <Link
          v-for="link in head.link"
          :id="link.id"
          :key="link.id"
          :rel="link.rel"
          :href="link.href"
          :hreflang="link.hreflang"
        />
        <Meta
          v-for="meta in head.meta"
          :id="meta.id"
          :key="meta.id"
          :property="meta.property"
          :content="meta.content"
        />
      </Head>
      <Body>
        <NuxtLayout>
          <NuxtPage />
        </NuxtLayout>
      </Body>
    </Html>
  </div>
</template>

<script setup lang="ts">
  const runtimConfig = useRuntimeConfig();

  //////////// Initial SEO/head data
  // i18n
  const locale = ref(useI18n().locale);
  const { t } = useI18n();
  const head = useLocaleHead({
    lang: true,
    dir: true,
    seo: true,
  });

  // Directus utils
  const { getSingletonItem } = useDirectusItems();
  const { getThumbnail } = useDirectusFiles();

  // Fetch data
  const { data, status, error, refresh } = await useAsyncData<GeneralInfo>("general_infos", () =>
    getSingletonItem({
      collection: "general_infos",
      params: {
        fields: ["*.*", "seo.*", "seo.image.*", "seo.translations.*"],
      },
    })
  );

  // Translation utils composable
  const { filterTranslations } = translationUtils<GeneralInfo>();

  // Only pass translated data of current locale and handle language switch
  const translatedData = computed(() => {
    if (!data.value) return null;
    return filterTranslations(data.value, locale.value);
  });

  // JSON-LD
  useSchemaOrg([
    defineOrganization({
      name: unref(translatedData)?.seo?.translations?.[0]?.title || t("nuxtSiteConfig.name"),
      url: runtimConfig.public.nuxtUrl ?? "https://www.felixstumpf.de",
      // sameAs: unref(translatedData)?.instagram || 'https://www.instagram.com/felix.stumpf/',
    }),
    defineWebSite({
      name: unref(translatedData)?.seo?.translations?.[0]?.title || t("nuxtSiteConfig.name"),
    }),
  ]);

  // Set meta
  if (translatedData.value?.seo) {
    // Head / title template
    useHead({
      titleTemplate: (titleChunk) => {
        const defaultTitle =
          unref(translatedData)?.seo?.translations?.[0]?.title || t("nuxtSiteConfig.name");

        if (defaultTitle === titleChunk) return titleChunk || null;

        return titleChunk ? `${titleChunk} - ${defaultTitle}` : defaultTitle;
      },
    });

    // Seo / Meta
    useSeoMeta({
      robots: "index,follow",
      description: () =>
        translatedData.value?.seo?.translations?.[0]?.description ||
        t("nuxtSiteConfig.description"),
      ogDescription: () =>
        translatedData.value?.seo?.translations?.[0]?.description ||
        t("nuxtSiteConfig.description"),
      // Image
      ogImage: () =>
        translatedData.value?.seo?.image?.id
          ? getThumbnail(translatedData.value?.seo?.image?.id, { width: 1200, height: 630 })
          : null,
      ogImageAlt: () => translatedData.value?.seo?.image?.description || null,
      ogImageWidth: () => translatedData.value?.seo?.image?.width || null,
      ogImageHeight: () => translatedData.value?.seo?.image?.height || null,
      twitterCard: "summary_large_image",
      twitterImage: () =>
        translatedData.value?.seo?.image?.id
          ? getThumbnail(translatedData.value?.seo?.image?.id, { width: 1200, height: 630 })
          : null,
      twitterImageWidth: () => translatedData.value?.seo?.image?.width || null,
      twitterImageHeight: () => translatedData.value?.seo?.image?.height || null,
    });
  }
</script>
