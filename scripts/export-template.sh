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

# Function to handle errors
handle_error() {
    echo -e "\n${ERROR}${BOLD}ERROR !!!${RESET}\n"
    exit 1
}

# Load .env file
set -a
source .env || handle_error
set +a

# Container name
DIRECTUS_CONTAINER_NAME="${PROJECT_NAME}__directus" || handle_error

# Export template
echo -e "\n${VIOLET}${BOLD}Extracting $PROJECT_NAME template to $TEMPLATE_DIR:${RESET}\n"
expect <<EOF
    set timeout -1

    # Start the command inside the Docker container
    spawn docker exec -it $DIRECTUS_CONTAINER_NAME npx directus-template-cli extract

    # 1. "What is the name of the template?"
    expect "What is the name of the template?.:"
    send "$PROJECT_NAME\r"

    # 2. "What directory would you like to extract the template to?"
    expect "What directory would you like to extract the template to? If it doesn't exist, it will be created."
    send "$TEMPLATE_DIR\r"

    # 3. "What is your Directus URL?"
    expect "What is your Directus URL?"
    send "$DIRECTUS_URL\r"

    # 4. "What is your Directus Admin Token?"
    expect "What is your Directus Admin Token?"
    send "$DIRECTUS_ADMIN_TOKEN\r"

    # Wait for the process to complete
    expect eof
EOF

if [ $? -eq 0 ]; then
    echo -e "\n${SUCCESS}Template extracted successfully to ./directus/$TEMPLATE_DIR!\n"
else
    handle_error
fi
