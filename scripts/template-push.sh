#!/bin/bash

#===========================================
# Directus Template Import Script
# Import a template to your Directus instance
# Version: 1.1
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

# Format timestamp from template name
format_date() {
    local timestamp=$1
    if [[ $timestamp =~ ^.*_([0-9]{4})([0-9]{2})([0-9]{2})_([0-9]{2})([0-9]{2})$ ]]; then
        echo "${BASH_REMATCH[1]}-${BASH_REMATCH[2]}-${BASH_REMATCH[3]} ${BASH_REMATCH[4]}:${BASH_REMATCH[5]}"
    else
        echo ""
    fi
}

# Format template name for display
format_template_name() {
    local template=$1
    local formatted_name
    local timestamp

    # Extract timestamp if present
    timestamp=$(format_date "$template")

    # Remove timestamp pattern from name if present
    formatted_name=$(echo "$template" | sed 's/_[0-9]\{8\}_[0-9]\{4\}$//')

    # Convert hyphens to spaces and capitalize words
    formatted_name=$(echo "$formatted_name" | tr '-' ' ' | awk '{for(i=1;i<=NF;i++)sub(/./,toupper(substr($i,1,1)),$i)}1')

    echo "$formatted_name;$timestamp"
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
# Template Selection Functions
#-------------------------------------------

# List available templates
list_templates() {
    print_header "Available Templates"

    # Check if templates directory exists
    if [ ! -d "./directus/templates" ]; then
        print_message "error" "Templates directory not found: ./directus/templates"
        exit 1
    fi

    # Get list of template directories
    templates=()
    while IFS= read -r -d '' dir; do
        template_name=$(basename "$dir")
        templates+=("$template_name")
    done < <(find "./directus/templates" -mindepth 1 -maxdepth 1 -type d -print0)

    # Check if any templates were found
    if [ ${#templates[@]} -eq 0 ]; then
        print_message "error" "No templates found in ./directus/templates"
        exit 1
    fi

    # Display templates with numbers and formatted names
    print_message "info" "Found ${#templates[@]} template(s):"
    echo
    printf "${BOLD}%3s  %-30s  %-19s${NC}\n" "#" "Template Name" "Created at"
    echo "─────────────────────────────────────────────────────────"

    for i in "${!templates[@]}"; do
        # Format template information
        IFS=';' read -r formatted_name timestamp <<< "$(format_template_name "${templates[$i]}")"

        # Print formatted template entry
        if [ -n "$timestamp" ]; then
            printf "${VIOLET}%3d${NC}  ${BLUE}%-30s${NC}  ${YELLOW}%s${NC}\n" "$((i+1))" "$formatted_name" "$timestamp"
        else
            printf "${VIOLET}%3d${NC}  ${BLUE}%-30s${NC}\n" "$((i+1))" "$formatted_name"
        fi
    done

    echo
    print_message "info" "Please select a template by entering its number (1-${#templates[@]})..."
    echo
}

# Select template
select_template() {
    local valid_selection=false
    local selection

    while [ "$valid_selection" = false ]; do
        read -r selection < /dev/tty  # Read directly from terminal

        # Validate input is a number
        if ! [[ "$selection" =~ ^[0-9]+$ ]]; then
            print_message "error" "Please enter a valid number"
            continue
        fi

        # Validate input is in range
        if [ "$selection" -lt 1 ] || [ "$selection" -gt "${#templates[@]}" ]; then
            print_message "error" "Please select a number between 1 and ${#templates[@]}"
            continue
        fi

        valid_selection=true
    done

    # Return selected template name (just the array value)
    echo "${templates[$((selection-1))]}"
}

# Confirm selection
confirm_selection() {
    local proceed

    echo -ne "\n${YELLOW}Apply template ? [y/n]:${NC} "
    read -r proceed

    if [[ ! "$proceed" =~ ^[Yy]$ ]]; then
        print_message "info" "Import cancelled by user"
        exit 0
    fi
}

#-------------------------------------------
# Template Import Functions
#-------------------------------------------

# Import Directus template
import_template() {
    local template_dir=$1

    print_header "Template Import"
    print_message "info" "Importing template for project: ${PROJECT_NAME}"
    print_message "info" "Template directory: ${template_dir}"

    npx directus-template-cli@latest apply -p \
        --directusUrl="${DIRECTUS_URL}" \
        --userEmail="${ADMIN_EMAIL}" \
        --userPassword="${ADMIN_PWD}" \
        --templateLocation="./directus/templates/${template_dir}" \
        --templateType="local" || {
            print_message "error" "Template import failed"
            exit 1
        }

    echo -e "\n"

    print_message "success" "Template '${template_dir}' imported successfully to ${DIRECTUS_URL}"
}

#-------------------------------------------
# Main Import Process
#-------------------------------------------

# Execute complete import process
import_all() {
    # List and select template
    list_templates
    SELECTED_TEMPLATE=$(select_template)
    confirm_selection "$SELECTED_TEMPLATE"

    # Execute import operation
    import_template "$SELECTED_TEMPLATE"

    # Remove logs
    rm -rf ./.directus-template-cli/logs
    rmdir ./.directus-template-cli

    # Display import summary
    print_header "Import Summary"
    print_message "success" "Template import completed successfully"
    print_message "info" "Imported template: ${SELECTED_TEMPLATE}"
    print_message "info" "Target URL: ${DIRECTUS_URL}"
}

#-------------------------------------------
# Main
#-------------------------------------------

main() {
    # Load configuration
    check_env_file
    validate_env_vars

    # Run import process
    import_all

    if [ $? -eq 0 ]; then
        exit 0
    else
        exit 1
    fi
}

main
