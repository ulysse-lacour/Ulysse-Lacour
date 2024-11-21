// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  compatibilityDate: "2024-04-03",

  future: {
    compatibilityVersion: 4,
  },

  // To experiment with :

  // https://masteringnuxt.com/blog/nuxt-islands
  // experimental: {
  //   componentIslands: true,
  // },

  // https://nuxt.com/modules/fontaine
  // https://dev.to/jacobandrewsky/improving-performance-of-nuxt-with-fontaine-5dim
  // fontMetrics: {
  //   fonts: ['Inter', 'Kalam'],
  // },

  // https://dev.to/jacobandrewsky/optimizing-css-performance-in-nuxt-with-critters-4k8i
  // critters: {
  //   // Options passed directly to critters: https://github.com/GoogleChromeLabs/critters#critters-2
  //   config: {
  //     // Default: 'media'
  //     preload: 'swap',
  //   },
  // },

  srcDir: "app",

  serverDir: "server",

  typescript: {
    typeCheck: true,
    strict: true,
    shim: true,
    tsConfig: {
      compilerOptions: {
        module: "ESNext",
        strict: true,
        // types: ['@pinia/nuxt'],
      },
    },
  },

  runtimeConfig: {
    public: {
      nuxtUrl: process.env.NUXT_URL,
      directusUrl: process.env.DIRECTUS_URL,
    },
    private: {
      directusAdminToken: process.env.DIRECTUS_ADMIN_TOKEN,
    },
  },

  modules: [
    "@nuxt/eslint",
    "@vueuse/nuxt",
    "@nuxtjs/i18n",
    [
      "@pinia/nuxt",
      {
        // Auto-import pinia main functions
        autoImports: ["defineStore", "storeToRefs"],
      },
    ],
    "nuxt-directus",
    "@nuxt/image",
    "@nuxtjs/seo",
    "@nuxt/icon",
    "@nuxt/fonts",
    "@nuxtjs/tailwindcss",
    "@nuxtjs/color-mode",
  ],

  // Components configuration - https://nuxt.com/docs/guide/directory-structure/components
  components: [
    {
      path: "@/components",
      pathPrefix: false,
    },
  ],

  directus: {
    url: process.env.DIRECTUS_URL,
    devtools: true,
  },

  imports: {
    // Auto-import pinia stores defined in `~/stores`
    dirs: ["stores"],

    imports: [
      {
        from: "tailwind-variants",
        name: "tv",
      },
      {
        from: "tailwind-variants",
        name: "VariantProps",
        type: true,
      },
    ],
  },

  devtools: { enabled: true },

  i18n: {
    vueI18n: "./i18n.config.ts",

    strategy: "no_prefix",

    baseUrl: process.env.NUXT_URL,

    detectBrowserLanguage: {
      useCookie: true,
      cookieKey: "i18n_redirected",
      redirectOn: "root",
    },

    langDir: "locales",

    lazy: true,

    // Available locales
    locales: [
      {
        code: "en",
        iso: "en-US",
        name: "English",
        dir: "ltr",
        file: "en.ts",
      },
      {
        code: "de",
        iso: "de-DE",
        name: "Deutsch",
        dir: "ltr",
        file: "de.ts",
      },
    ],
    defaultLocale: "en",
    defaultDirection: "ltr",

    // Custom route translations
    // customRoutes: "config",
    // pages: {
    //   "project/[slug]": {
    //     de: "/projet/[slug]",
    //     en: "/project/[slug]",
    //   },
    // },
  },

  css: [
    "@/assets/scss/main.scss",
    "@/../node_modules/video.js/dist/video-js.css",
    "@/../node_modules/vue3-carousel/dist/carousel.css",
  ],

  postcss: {
    plugins: {
      "tailwindcss/nesting": {},
      tailwindcss: {},
      autoprefixer: {},
    },
  },

  // Image Configuration - https://image.nuxt.com/providers/directus
  image: {
    provider: "directus",
    directus: {
      baseURL: `${process.env.DIRECTUS_URL}/assets/`,
      modifiers: {
        format: "auto",
      },
    },
  },

  // Nuxt SEO - https://nuxtseo.com/nuxt-seo/getting-started/what-is-nuxt-seo
  site: {
    url: process.env.NUXT_URL || "http://localhost:3003",
  },

  // Sitemap Configuration - https://nuxtseo.com/sitemap/getting-started/how-it-works
  // Creating dynamic pages for sitemap in server/api/__sitemap__/urls.ts
  sitemap: {
    sources: ["/api/__sitemap__/urls"],
  },

  // Link checker - https://nuxtseo.com/link-checker/guides/build-scans
  linkChecker: {
    failOnError: true,
    report: {
      html: true,
      markdown: true,
    },
  },

  tailwindcss: {
    exposeConfig: true,
    editorSupport: true,
  },

  colorMode: {
    classSuffix: "",
  },
});