// TODO : try to replace this Schema.org
// https://nuxtseo.com/schema-org/guides/full-documentation
// https://unhead.unjs.io/schema-org/schema/website

export default defineNitroPlugin(async (nitroApp) => {
  try {
    const seo = await directusServer.request(
      readSingleton("general_infos", {
        fields: ["*", { seo: ["*", { translations: ["*"] }] }],
      })
    );
    const config = {
      name: seo.seo?.translations ? seo.seo?.translations[0]?.title : "",
      description: seo.seo?.translations ? seo.seo?.translations[0]?.description : "",
    };
    if (seo.seo?.translations) {
      nitroApp.hooks.hook("site-config:init", ({ siteConfig }) => {
        siteConfig.push(config);
      });
    }
  } catch (error) {
    console.error(error);
  }
});
