#!/bin/sh

# Directus Backup Script
# Usage: sh backup.sh
# Creates timestamped backups of database and uploads in /directus/backups

BACKUP_DIR="/directus/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M)
MAX_BACKUPS=4

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

backup_database() {
    section "Database Backup"
    mkdir -p "${BACKUP_DIR}"

    log "INFO" "Starting database backup..."
    if PGPASSWORD="${DB_PASSWORD}" pg_dump \
        -h "${DB_HOST}" \
        -p "${DB_PORT}" \
        -U "${DB_USER}" \
        -d "${DB_DATABASE}" \
        --clean \
        --if-exists \
        -F p > "${BACKUP_DIR}/${TIMESTAMP}_db.sql"; then

        size=$(du -h "${BACKUP_DIR}/${TIMESTAMP}_db.sql" | cut -f1)
        log "OK" "Database backup completed (${size})"
        return 0
    else
        log "ERROR" "Database backup failed"
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
    if tar -czf "${BACKUP_DIR}/${TIMESTAMP}_uploads.tar.gz" -C /directus/uploads .; then
        size=$(du -h "${BACKUP_DIR}/${TIMESTAMP}_uploads.tar.gz" | cut -f1)
        log "OK" "Uploads backup completed (${size})"
        return 0
    else
        log "ERROR" "Uploads backup failed"
        return 1
    fi
}

cleanup_old_backups() {
    section "Cleanup Old Backups"

    # Count existing backup sets (counting only database backups as reference)
    backup_count=$(ls -1 "${BACKUP_DIR}"/*_db.sql 2>/dev/null | wc -l)

    if [ "$backup_count" -ge "$MAX_BACKUPS" ]; then
        log "INFO" "Found ${backup_count} backups, cleaning up old ones..."

        # Get the oldest backup timestamp
        oldest_backup=$(ls -1 "${BACKUP_DIR}"/*_db.sql | sort | head -n 1 | sed 's/.*\/\([0-9]\{8\}_[0-9]\{4\}\).*/\1/')

        if [ -n "$oldest_backup" ]; then
            # Remove both database and uploads backup for the oldest timestamp
            rm -f "${BACKUP_DIR}/${oldest_backup}_db.sql"
            rm -f "${BACKUP_DIR}/${oldest_backup}_uploads.tar.gz"
            log "OK" "Removed backup set from ${oldest_backup}"
        fi
    else
        log "INFO" "No cleanup needed (${backup_count}/${MAX_BACKUPS} backup sets)"
    fi
}

check_environment() {
    missing=""
    printf "\n"

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
    if check_environment; then
        cleanup_old_backups && backup_database && backup_uploads
    fi
}

main
