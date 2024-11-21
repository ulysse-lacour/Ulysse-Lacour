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

echo -e "\n${VIOLET}${BOLD}Running apps in dev mode :${RESET}\n"

# Function to handle errors
handle_error() {
    echo -e "\n${ERROR}${BOLD}ERROR !!!${RESET}\n"
    exit 1
}

# Use right node version
echo -e "\n${DEFAULT}Using right node version :${RESET}\n"
. ~/.nvm/nvm.sh || handle_error
nvm use 20.14 || handle_error

# Load .env file
set -a
source .env || handle_error
set +a

# Install Nuxt dependencies
echo -e "\n${DEFAULT}Installing Nuxt dependencies :${RESET}\n"
(cd ./nuxt && pnpm install) || handle_error

# Build docker images
echo -e "\n${DEFAULT}Building docker images :${RESET}\n"
docker compose -f compose.dev.yml build --no-cache

# Mount docker containers
echo -e "\n${DEFAULT}Mounting docker containers :${RESET}\n"
docker compose -f compose.dev.yml up -d || handle_error

# Success message
echo -e "\n\n${SUCCESS}Dockerized apps up and running on localhost!${RESET}\n"

# Apps link display
echo -e "\n${DEFAULT}Directus running on : ${BOLD}${YELLOW}http://localhost:${DIRECTUS_PORT} ${RESET}\n"
echo -e "${DEFAULT}Nuxt running on : ${BOLD}${YELLOW}http://localhost:${NUXT_PORT} ${RESET}\n"
