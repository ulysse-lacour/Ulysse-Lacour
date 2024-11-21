import eslintPluginPrettierRecommended from "eslint-plugin-prettier/recommended";

import withNuxt from "./.nuxt/eslint.config.mjs";

export default withNuxt(eslintPluginPrettierRecommended, {
  ignores: ["**/node_modules/", "**/.nuxt/", "**/.output/"],
  rules: {
    "prettier/prettier": "off",
    "arrow-body-style": "off",
    "prefer-arrow-callback": "off",
    "@typescript-eslint/no-inferrable-types": "off",
    "no-unused-vars": "off",
    "@typescript-eslint/no-unused-vars": "warn",
    "@typescript-eslint/no-explicit-any": "off",
    "vue/multi-word-component-names": "off",
    semi: "off",
    "vue/v-on-style": "off",
    "vue/no-v-html": "off",
    "vue/require-default-prop": "off",
  },
});
