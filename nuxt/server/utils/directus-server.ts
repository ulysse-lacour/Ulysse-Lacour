import {
  createDirectus,
  createItem,
  readItem,
  readItems,
  readSingleton,
  rest,
  staticToken,
  updateItem,
  withToken,
} from "@directus/sdk";

const directusUrl = process.env.DIRECTUS_URL as string;

const directusServer = createDirectus<Collections>(directusUrl)
  .with(rest())
  .with(staticToken(process.env.DIRECTUS_ADMIN_TOKEN as string));

export { directusServer, readItem, readItems, readSingleton, createItem, updateItem, withToken };
