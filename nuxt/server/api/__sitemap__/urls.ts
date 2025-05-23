interface SitemapEntry {
  loc: string;
  lastmod: string | null;
  changefreq: string | null;
  priority: number;
}

// get functions are fetching data from Directus and return an array of entries pretty formatted for sitemap
interface Page {
  slug: string;
  date_created: string | null;
  date_updated: string | null;
}

async function getPages() {
  try {
    const pages = await directusServer.request(
      readItems("pages", {
        fields: ["slug", "date_created", "date_updated"],
        filter: {
          status: {
            _eq: "published",
          },
        },
        limit: -1,
      })
    );

    const entries: SitemapEntry[] = pages.map((page: Page) => {
      return {
        loc: `${page.slug}`,
        lastmod: page.date_updated || page.date_created,
        changefreq: "monthly",
        priority: 0.5,
      };
    });
    return entries;
  } catch (error) {
    console.error(error);
    const entries: Array<any> = [];
    return entries;
  }
}

export default defineEventHandler(async () => {
  try {
    const [pages] = await Promise.all([getPages()]);
    return [...pages];
  } catch (error) {
    console.error(error);
    return [];
  }
});
