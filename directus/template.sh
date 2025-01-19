#!/bin/sh

# Directus templates managements cripts
# Usage: sh template.sh pull || sh template.sh push
# Export/Import Directus templates

TEMPLATES_DIR="/directus/templates"
TIMESTAMP=$(date +%Y%m%d_%H%M)

log() {
    case $1 in
        "INFO")  printf "→ %s\n" "$2" ;;
        "OK")    printf "✓ %s\n" "$2" ;;
        "ERROR") printf "✗ %s\n" "$2" ;;
    esac
}

section() {
    printf "\n=== %s ===\n\n" "$1"
}

format_date() {
    echo "$1" | sed 's/\([0-9]\{4\}\)\([0-9]\{2\}\)\([0-9]\{2\}\)_\([0-9]\{2\}\)\([0-9]\{2\}\)/\1-\2-\3 \4:\5/'
}

list_templates() {
    local count=0
    printf "\nAvailable templates:\n"
    printf "%-4s %-20s %s\n" "No." "Date" "Name"
    printf "%s\n" "----------------------------------------"

    for template_dir in $(ls -1d "${TEMPLATES_DIR}"/* 2>/dev/null | sort -r); do
        if [ -d "$template_dir" ]; then
            count=$((count + 1))
            timestamp=$(basename "$template_dir" | grep -o '[0-9]\{8\}_[0-9]\{4\}' || echo "Unknown")
            template_name=$(basename "$template_dir")
            if [ "$timestamp" != "Unknown" ]; then
                date=$(format_date "$timestamp")
            else
                date="Unknown date"
            fi
            printf "%-4s %-20s %s\n" "$count." "$date" "$template_name"
            TEMPLATE_DIRS="$TEMPLATE_DIRS $template_dir"
        fi
    done

    if [ $count -eq 0 ]; then
        log "ERROR" "No templates found"
        return 1
    fi

    printf "\nSelect template to import (1-$count): "
    read -r selection

    if ! [ "$selection" -ge 1 ] 2>/dev/null || [ "$selection" -gt "$count" ]; then
        log "ERROR" "Invalid selection"
        return 1
    fi

    SELECTED_TEMPLATE=$(echo $TEMPLATE_DIRS | cut -d' ' -f$selection)
    return 0
}

export_template() {
    section "Export template"
    mkdir -p "/directus/templates/${PROJECT_NAME}_${TIMESTAMP}"

    log "INFO" "Starting template export..."
    echo -e "\n"

    npx directus-template-cli extract -p \
        --directusUrl="${PUBLIC_URL}" \
        --userEmail="${ADMIN_EMAIL}" \
        --userPassword="${ADMIN_PASSWORD}" \
        --templateName="${PROJECT_NAME}_${TIMESTAMP}" \
        --templateLocation="/directus/templates/${PROJECT_NAME}_${TIMESTAMP}" || {
            log "ERROR" "Unable to export template..."
            exit 1
        }
}

import_template() {
    section "Import template"

    if ! list_templates; then
        exit 1
    fi

    # Extract template name from the selected directory path
    TEMPLATE_NAME=$(basename "${SELECTED_TEMPLATE}")

    log "INFO" "Starting template import..."
    echo -e "\n"

    npx directus-template-cli apply -p \
        --directusUrl="${PUBLIC_URL}" \
        --userEmail="${ADMIN_EMAIL}" \
        --userPassword="${ADMIN_PASSWORD}" \
        --templateLocation="${SELECTED_TEMPLATE}" \
        --templateType="local" || {
            log "ERROR" "Unable to import template..."
            exit 1
        }
}

check_environment() {
    missing=""
    printf "\n"

    for var in PROJECT_NAME PUBLIC_URL ADMIN_EMAIL ADMIN_PASSWORD; do
        if [ -z "$(eval echo \$${var})" ]; then
            missing="${missing} ${var}"
        fi
    done

    if [ -n "$missing" ]; then
        log "ERROR" "Missing required variables:${missing}"
        return 1
    fi

    return 0
}

main() {
    # Check if command line argument is provided
    if [ $# -eq 0 ]; then
        log "ERROR" "No argument provided. Usage: sh template.sh pull || sh template.sh push"
        exit 1
    fi

    # Validate environment variables
    if ! check_environment; then
        exit 1
    fi

    # Handle command line argument
    case "$1" in
        "pull")
            export_template
            echo -e "\n"
            log "OK" "Template exported successfully"
            ;;
        "push")
            import_template
            echo -e "\n"
            log "OK" "Template imported successfully"
            ;;
        *)
            echo -e "\n"
            log "ERROR" "Invalid argument. Usage: sh template.sh pull || sh template.sh push"
            exit 1
            ;;
    esac
}

main "$@"
