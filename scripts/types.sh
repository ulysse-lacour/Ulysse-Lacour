#!/bin/bash

#===========================================
# Script to Export Directus Types to Nuxt
# Version: 1.0
#===========================================

#-------------------------------------------
# Color Configuration
#-------------------------------------------

# Text formatting
BOLD='\033[1m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

#-------------------------------------------
# Utility Functions
#-------------------------------------------

# Print formatted message with emoji indicators
print_message() {
    local type=$1
    local message=$2
    case $type in
        "info") echo -e "${BLUE}ℹ️  ${message}${NC}" ;;
        "success") echo -e "${GREEN}✅ ${message}${NC}" ;;
        "error") echo -e "${RED}❌ ${message}${NC}" ;;
        "warning") echo -e "${YELLOW}⚠️  ${message}${NC}" ;;
        *) echo -e "$message" ;;
    esac
}

# Print section header with clear separation
print_header() {
    echo -e "\n${BOLD}${BLUE}=== $1 ===${NC}\n"
}

#-------------------------------------------
# Environment Configuration
#-------------------------------------------

# Load and validate environment configuration
check_env_file() {
    print_header "Environment Check"
    if [ ! -f ".env" ]; then
        print_message "error" "Environment file not found: .env"
        exit 1
    }
    print_message "info" "Loading environment variables..."
    set -a
    source .env
    set +a
    print_message "success" "Environment loaded successfully"
}

# Verify all required variables are set
validate_env_vars() {
    local required_vars=(
    "PROJECT_NAME"
    )
    local missing_vars=()

    for var in "${required_vars[@]}"; do
        if [ -z "${!var}" ]; then
            missing_vars+=("$var")
        fi
    done

    if [ ${#missing_vars[@]} -ne 0 ]; then
        echo -e "\n"
        print_message "error" "Missing required environment variables:"
        for var in "${missing_vars[@]}"; do
            echo "  - $var"
        done
        echo -e "\n"
        exit 1
    fi
}

#-------------------------------------------
# Type Export Functions
#-------------------------------------------

# Set container names
set_container_names() {
    DIRECTUS_CONTAINER_NAME="${PROJECT_NAME}__directus"
    NUXT_CONTAINER_NAME="${PROJECT_NAME}__nuxt"
    TYPES_FILE_PATH="./directus/types/Directus.d.ts"
}

# Export types from Directus
export_types() {
    print_header "Exporting Types"
    print_message "info" "Exporting types from Directus..."
    docker exec -it $DIRECTUS_CONTAINER_NAME npx directus models snapshot ./types/Directus.d.ts
    if [ $? -eq 0 ]; then
        print_message "success" "Types exported successfully"
    else
        print_message "error" "Failed to export types"
        exit 1
    fi
}

# Clean and format types file
clean_types_file() {
    print_header "Cleaning Types File"
    print_message "info" "Processing Directus.d.ts file..."

    # Remove ID and slug patterns
    sed -E -i.bak 's/[a-zA-Z0-9_]+\["id"\] \| //g' $TYPES_FILE_PATH
    sed -E -i.bak 's/[a-zA-Z0-9_]+\["slug"\] \| //g' $TYPES_FILE_PATH

    # Wrap content with declare global
    awk 'BEGIN { print "declare global {" } { print } END { print "} export {};" }' $TYPES_FILE_PATH > tmp && mv tmp $TYPES_FILE_PATH

    if [ $? -eq 0 ]; then
        print_message "success" "Types file cleaned successfully"
    else
        print_message "error" "Failed to clean types file"
        exit 1
    fi
}

# Copy types to Nuxt
copy_types_to_nuxt() {
    print_header "Copying Types to Nuxt"
    print_message "info" "Transferring types to Nuxt application..."
    cp $TYPES_FILE_PATH ./nuxt/app/types/Directus.d.ts

    if [ $? -eq 0 ]; then
        print_message "success" "Types transferred to: ./nuxt/app/types/Directus.d.ts"
    else
        print_message "error" "Failed to copy types to Nuxt"
        exit 1
    fi
}

#-------------------------------------------
# Main Function
#-------------------------------------------

main() {
    print_header "Directus Types Export"

    check_env_file
    set_container_names
    export_types
    clean_types_file
    copy_types_to_nuxt

    echo -e "\n"
    if [ $? -eq 0 ]; then
        exit 0
    else
        exit 1
    fi
}

#-------------------------------------------
# Execute Main
#-------------------------------------------
main
