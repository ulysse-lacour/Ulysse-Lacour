#!/bin/sh

# Directus Backup Script
# Usage: sh backup.sh [database|uploads|all]
# Creates timestamped backups of database and/or uploads in /directus/backups

BACKUP_DIR="/directus/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M)

# Minimal terminal formatting
BOLD="[1m"
RESET="[0m"

log() {
    case $1 in
        "INFO")  printf "→ %s\n" "$2" ;;
        "OK")    printf "✓ %s\n" "$2" ;;
        "ERROR") printf "✗ %s\n" "$2" ;;
    esac
}

section() {
    printf "\n${BOLD}=== %s ===${RESET}\n\n" "$1"
}

backup_database() {
    section "Database Backup"
    mkdir -p "${BACKUP_DIR}"

    log "INFO" "Creating backup metadata..."
    cat > "${BACKUP_DIR}/backup_${TIMESTAMP}.meta" << EOF
DB_NAME=${DB_DATABASE}
DB_USER=${DB_USER}
DB_HOST=${DB_HOST}
DB_PORT=${DB_PORT}
BACKUP_DATE=$(date '+%Y-%m-%d %H:%M')
HOSTNAME=$(hostname)
EOF

    log "INFO" "Starting database backup..."
    if PGPASSWORD="${DB_PASSWORD}" pg_dump \
        -h "${DB_HOST}" \
        -p "${DB_PORT}" \
        -U "${DB_USER}" \
        -d "${DB_DATABASE}" \
        --clean \
        --if-exists \
        -F p > "${BACKUP_DIR}/backup_${TIMESTAMP}.sql"; then

        size=$(du -h "${BACKUP_DIR}/backup_${TIMESTAMP}.sql" | cut -f1)
        log "OK" "Database backup completed (${size})"
        return 0
    else
        log "ERROR" "Database backup failed"
        rm -f "${BACKUP_DIR}/backup_${TIMESTAMP}.meta"
        return 1
    fi
}

backup_uploads() {
    section "Uploads Backup"
    mkdir -p "${BACKUP_DIR}"

    if [ ! -d "/directus/uploads" ]; then
        log "ERROR" "Uploads directory not found"
        return 1
    fi

    log "INFO" "Starting uploads backup..."
    if tar -czf "${BACKUP_DIR}/uploads_${TIMESTAMP}.tar.gz" -C /directus/uploads .; then
        size=$(du -h "${BACKUP_DIR}/uploads_${TIMESTAMP}.tar.gz" | cut -f1)
        log "OK" "Uploads backup completed (${size})"
        return 0
    else
        log "ERROR" "Uploads backup failed"
        return 1
    fi
}

check_environment() {
    missing=""
    for var in DB_DATABASE DB_USER DB_PASSWORD DB_HOST DB_PORT; do
        if [ -z "$(eval echo \$${var})" ]; then
            missing="${missing} ${var}"
        fi
    done

    if [ -n "$missing" ]; then
        log "ERROR" "Missing required variables:${missing}"
        return 1
    fi

    log "INFO" "Database: ${DB_DATABASE} @ ${DB_HOST}:${DB_PORT}"
    return 0
}

main() {
    section "Backup Started $(date '+%Y-%m-%d %H:%M')"
    start_time=$(date +%s)

    case "$1" in
        database)
            check_environment && backup_database
            ;;
        uploads)
            backup_uploads
            ;;
        all)
            if check_environment; then
                backup_database && backup_uploads
            fi
            ;;
        *)
            log "ERROR" "Usage: $0 [database|uploads|all]"
            exit 1
            ;;
    esac

    status=$?
    end_time=$(date +%s)
    section "Backup Completed"
    log "INFO" "Duration: $((end_time - start_time)) seconds"
    exit $status
}

main "$1"
