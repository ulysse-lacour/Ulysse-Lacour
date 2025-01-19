#!/bin/bash

#===========================================
# Directus Template Export Script
# Exports Directus instance as a template
# Version: 1.0
#===========================================

#-------------------------------------------
# Color Configuration and Utility Functions
#-------------------------------------------

# Text formatting
BOLD='\033[1m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
VIOLET='\033[0;35m'
NC='\033[0m' # No Color

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
    fi
    print_message "info" "Loading environment variables..."
    set -a
    source .env
    set +a
    print_message "success" "Environment loaded successfully"
}

# Verify all required variables are set
validate_env_vars() {
    local required_vars=("PROJECT_NAME" "DIRECTUS_URL" "ADMIN_EMAIL" "ADMIN_PWD")
    local missing_vars=()

    for var in "${required_vars[@]}"; do
        if [ -z "${!var}" ]; then
            missing_vars+=("$var")
        fi
    done

    if [ ${#missing_vars[@]} -ne 0 ]; then
        print_message "error" "Missing required environment variables:"
        for var in "${missing_vars[@]}"; do
            echo "  - $var"
        done
        exit 1
    fi
}

#-------------------------------------------
# Template Export Functions
#-------------------------------------------

# Set up template export directory
setup_export_dir() {
    print_header "Export Directory Setup"
    print_message "info" "Using template directory: ${TEMPLATE_DIR}"

    print_message "info" "Creating export directory..."
    mkdir -p "./directus/$TEMPLATE_DIR" || {
        print_message "error" "Failed to create template directory"
        exit 1
    }
}

# Export Directus template
export_template() {
    local template_dir=$1

    print_header "Template Export"
    print_message "info" "Exporting template for project: ${PROJECT_NAME}"

    npx directus-template-cli@latest extract -p \
        --directusUrl="${DIRECTUS_URL}" \
        --userEmail="${ADMIN_EMAIL}" \
        --userPassword="${ADMIN_PWD}" \
        --templateName="${PROJECT_NAME}_${TIMESTAMP}" \
        --templateLocation="./directus/${template_dir}" || {
            print_message "error" "Template export failed"
            exit 1
        }

    echo -e "\n"
}

#-------------------------------------------
# Main Export Process
#-------------------------------------------

# Execute complete export process
export_all() {
    # Initialize variables
    TIMESTAMP=$(date +%Y%m%d_%H%M)
    TEMPLATE_DIR="templates/${PROJECT_NAME}_${TIMESTAMP}"

    # Execute export operations
    setup_export_dir
    export_template "$TEMPLATE_DIR"

    # Remove logs
    rm -rf ./.directus-template-cli/logs
    rmdir ./.directus-template-cli

    # Display export summary
    print_header "Export Summary"
    print_message "success" "Template exported successfully to: ./directus/${template_dir}"
}

#-------------------------------------------
# Main
#-------------------------------------------

main() {
    # Load configuration
    check_env_file
    validate_env_vars

    # Run export process
    export_all

    if [ $? -eq 0 ]; then
        exit 0
    else
        exit 1
    fi
}

main
