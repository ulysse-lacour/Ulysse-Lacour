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

echo -e "\n${VIOLET}${BOLD}Running apps in with prod setup :${RESET}\n"

# Function to handle errors
handle_error() {
    echo -e "\n${ERROR}${BOLD}ERROR !!!${RESET}\n"
    exit 1
}

## Lint nuxt app
echo -e "\n${DEFAULT}Linting Nuxt app :${RESET}"
(cd ./nuxt && pnpm lintfix) || handle_error

# Use a subshell to only temporarily export environment variables
(
    # Load .env file for script
    set -a
    source .env.prod || handle_error
    set +a

    # Build docker images using prod env file
    echo -e "\n${DEFAULT}Building docker images :${RESET}\n"
    export $(grep -v '^#' .env.prod | grep -v '^$' | xargs) && docker compose -f compose.prod.yml build --no-cache

    # Mount docker containers
    echo -e "\n${DEFAULT}Mounting docker containers :${RESET}\n"
    docker compose -f compose.prod.yml up -d || handle_error

    # Success message
    echo -e "\n\n${SUCCESS}Preview production apps :${RESET}"

    # Apps link display
    echo -e "\n${DEFAULT}Directus running on :${BOLD}${YELLOW} ${DIRECTUS_URL} ${RESET}\n"
    echo -e "${DEFAULT}Nuxt running on :${BOLD}${YELLOW} http://localhost:${NUXT_PORT} ${RESET}\n"
)
