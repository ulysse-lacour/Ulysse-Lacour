#!/bin/sh

# Directus Restore Script
# Usage: sh restore.sh
# Restores database and uploads from backups in /directus/backups

BACKUP_DIR="/directus/backups"

log() {
    case $1 in
        "INFO")  printf "→ %s\n" "$2" ;;
        "OK")    printf "✓ %s\n" "$2" ;;
        "ERROR") printf "✗ %s\n" "$2" ;;
        "WARN")  printf "! %s\n" "$2" ;;
    esac
}

section() {
    printf "\n=== %s ===\n\n" "$1"
}

format_date() {
    echo "$1" | sed 's/\([0-9]\{4\}\)\([0-9]\{2\}\)\([0-9]\{2\}\)_\([0-9]\{2\}\)\([0-9]\{2\}\)/\1-\2-\3 \4:\5/'
}

list_backups() {
    local count=0
    printf "\nAvailable backups:\n"
    printf "%-4s %-20s %s\n" "No." "Date" "Size"
    printf "%s\n" "----------------------------------------"

    for sql_file in $(ls -1 "${BACKUP_DIR}"/*_db.sql 2>/dev/null | sort -r); do
        timestamp=$(echo "$sql_file" | sed 's/.*\([0-9]\{8\}_[0-9]\{4\}\)_db.sql/\1/')
        if [ -f "${BACKUP_DIR}/${timestamp}_uploads.tar.gz" ]; then
            count=$((count + 1))
            size=$(du -sh "$sql_file" | cut -f1)
            date=$(format_date "$timestamp")
            printf "%-4s %-20s %s\n" "$count." "$date" "$size"
            TIMESTAMPS="$TIMESTAMPS $timestamp"
        fi
    done

    if [ $count -eq 0 ]; then
        log "ERROR" "No complete backups found"
        return 1
    fi

    printf "\nSelect backup to restore (1-$count): "
    read -r selection

    if ! [ "$selection" -ge 1 ] 2>/dev/null || [ "$selection" -gt "$count" ]; then
        log "ERROR" "Invalid selection"
        return 1
    fi

    SELECTED_TIMESTAMP=$(echo $TIMESTAMPS | cut -d' ' -f$selection)
    return 0
}

restore_database() {
    local timestamp=$1
    section "Database Restore"

    log "INFO" "Terminating existing connections..."
    PGPASSWORD="${DB_PASSWORD}" psql \
        -h "${DB_HOST}" \
        -p "${DB_PORT}" \
        -U "${DB_USER}" \
        -d "postgres" \
        -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname='${DB_DATABASE}' AND pid<>pg_backend_pid();" >/dev/null 2>&1

    log "INFO" "Dropping and recreating database..."
    PGPASSWORD="${DB_PASSWORD}" psql \
        -h "${DB_HOST}" \
        -p "${DB_PORT}" \
        -U "${DB_USER}" \
        -d "postgres" \
        -c "DROP DATABASE IF EXISTS \"${DB_DATABASE}\";" >/dev/null 2>&1

    PGPASSWORD="${DB_PASSWORD}" psql \
        -h "${DB_HOST}" \
        -p "${DB_PORT}" \
        -U "${DB_USER}" \
        -d "postgres" \
        -c "CREATE DATABASE \"${DB_DATABASE}\" WITH OWNER = \"${DB_USER}\";" >/dev/null 2>&1

    log "INFO" "Restoring database from backup..."
    if PGPASSWORD="${DB_PASSWORD}" psql \
        -h "${DB_HOST}" \
        -p "${DB_PORT}" \
        -U "${DB_USER}" \
        -d "${DB_DATABASE}" \
        -f "${BACKUP_DIR}/${timestamp}_db.sql" >/dev/null 2>&1; then
        log "OK" "Database restored successfully"
        return 0
    else
        log "ERROR" "Database restore failed"
        return 1
    fi
}

restore_uploads() {
    local timestamp=$1
    section "Uploads Restore"

    if [ ! -f "${BACKUP_DIR}/${timestamp}_uploads.tar.gz" ]; then
        log "ERROR" "Uploads backup not found"
        return 1
    fi

    log "INFO" "Clearing existing uploads..."
    rm -rf /directus/uploads/*

    log "INFO" "Restoring uploads from backup..."
    if tar -xzf "${BACKUP_DIR}/${timestamp}_uploads.tar.gz" -C /directus/uploads/; then
        log "OK" "Uploads restored successfully"
        return 0
    else
        log "ERROR" "Uploads restore failed"
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
    section "Restore Started $(date '+%Y-%m-%d %H:%M')"
    start_time=$(date +%s)

    if ! check_environment; then
        exit 1
    fi

    if ! list_backups; then
        exit 1
    fi

    printf "\nThis will overwrite both database and uploads. Continue? (y/N): "
    read -r confirm
    case $confirm in
        [Yy]*)
            if restore_database "$SELECTED_TIMESTAMP" && restore_uploads "$SELECTED_TIMESTAMP"; then
                end_time=$(date +%s)
                section "Restore Completed"
                log "INFO" "Duration: $((end_time - start_time)) seconds"
                exit 0
            else
                log "ERROR" "Restore failed"
                exit 1
            fi
            ;;
        *)
            log "INFO" "Restore cancelled"
            exit 0
            ;;
    esac
}

main
