import { blackA } from "@radix-ui/colors";

/** @type {import('tailwindcss').Config} */
export default {
  content: ["./**/*.vue"],
  theme: {
    extend: {
      colors: {
        ...blackA,
      },
    },
  },
  plugins: [],
};
