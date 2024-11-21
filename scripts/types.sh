#!/bin/bash

# Styles
DEFAULT='\x1b[36;1m'
SUCCESS='\x1b[32;1m'
ERROR='\x1b[31;43;1m'
YELLOW='\x1b[33;1m'
VIOLET='\x1b[35;1m'
BOLD='\x1b[1m'
UNDERLINE='\x1b[4m'
RESET='\x1b[0m'

echo -e "\n${VIOLET}${BOLD}Exporting Directus types to Nuxt app :${RESET}\n"

# Function to handle errors
handle_error() {
    echo -e "\n${ERROR}${BOLD}ERROR !!!${RESET}\n"
    exit 1
}

# Load .env file
set -a
source .env || handle_error
set +a

# Containers name
STRAPI_CONTAINER_NAME="${PROJECT_NAME}__directus" || handle_error
NUXT_CONTAINER_NAME="${PROJECT_NAME}__nuxt" || handle_error

# Path to the generated types file
TYPES_FILE_PATH="./directus/types/Directus.d.ts"

# Export data
echo -e "\n${DEFAULT}Export Types :${RESET}"
docker exec -it $STRAPI_CONTAINER_NAME npx directus models snapshot ./types/Directus.d.ts || handle_error

# Clean the generated Directus.d.ts file
echo -e "\n${DEFAULT}Cleaning the generated Directus.d.ts file:${RESET}"

# Remove occurrences of any "singleword['id'] | " pattern
sed -E -i.bak 's/[a-zA-Z0-9_]+\["id"\] \| //g' $TYPES_FILE_PATH || handle_error

# Remove occurrences of any "singleword['slug'] | " pattern
sed -E -i.bak 's/[a-zA-Z0-9_]+\["slug"\] \| //g' $TYPES_FILE_PATH || handle_error

# Wrap the content of the file with "declare global { } export {};"
awk 'BEGIN { print "declare global {" } { print } END { print "} export {};" }' $TYPES_FILE_PATH > tmp && mv tmp $TYPES_FILE_PATH || handle_error

# Copy types file to nuxt
cp $TYPES_FILE_PATH ./nuxt/app/types/Directus.d.ts || handle_error

echo -e "\n${SUCCESS}Data exported, formated and transferred to: ${YELLOW}${BOLD}./nuxt/app/types/Directus.d.ts${RESET}\n"
