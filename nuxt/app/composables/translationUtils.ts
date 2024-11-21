// Utility type for base item, allowing for flexible objects with optional translations array
interface BaseItem {
  translations?: Array<any> | null;
  [key: string]: any;
}

// Utility type to recursively handle nested objects that extend BaseItem
type RecursiveItem<T> = {
  [K in keyof T]: T[K] extends BaseItem ? RecursiveItem<T[K]> : T[K];
};

// Composable function to filter and sort translations based on the current locale
export const translationUtils = <T extends BaseItem>() => {
  const filterTranslations = (item: T, locale: Language["code"]): RecursiveItem<T> => {
    // If the item is an array, apply filterTranslations to each element
    if (Array.isArray(item)) {
      return item.map((subItem) => filterTranslations(subItem, locale)) as RecursiveItem<T>;
    }

    // Shallow copy of the item to avoid mutating the original object
    const result: any = { ...item };

    // Handle translations array if it exists
    if (result.translations) {
      // Find the index of the translation that matches the current locale
      const translationIndex = result.translations.findIndex(
        (t: any) => t.languages_code === locale
      );

      if (translationIndex > -1) {
        // Get the translation for the current locale
        const currentTranslation = result.translations[translationIndex];

        // Fill missing keys in the current locale's translation with values from other translations
        result.translations.forEach((t: any) => {
          if (t.languages_code !== locale) {
            for (const key in t) {
              if (!currentTranslation[key]) {
                currentTranslation[key] = t[key];
              }
            }
          }
        });

        // Move the current locale's translation to the first position in the array
        result.translations.splice(translationIndex, 1);
        result.translations.unshift(currentTranslation);
      } else {
        // If no translation for the current locale is found, the translations array remains unchanged
      }
    }

    // Recursively apply filterTranslations to nested objects
    for (const key in result) {
      if (result[key] && typeof result[key] === "object") {
        result[key] = filterTranslations(result[key], locale);
      }
    }

    return result as RecursiveItem<T>;
  };

  return { filterTranslations };
};
