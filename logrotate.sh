#!/bin/bash

REQUIRED_CMDS=("find" "awk" "gzip" "cp" "mv" "date" "mkdir" "basename")

check_commands() {
  local missing=()
  for cmd in "${REQUIRED_CMDS[@]}"; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      missing+=("$cmd")
    fi
  done

  if [ ${#missing[@]} -ne 0 ]; then
    echo "Error: The following required command(s) are missing: ${missing[*]}"
    exit 1
  fi
}

check_commands

LOG_DIR="/var/log/apps"
DATE_SUFFIX=""
FILE_PATTERN="*.log"
CUSTOM_PATH_USED=false
RETENTION_DAYS=""
DRY_RUN=false

show_help() {
  echo "Usage: $0 [-H] [-D] [-p /path/to/logs] [-f file_pattern] [-r days] [-n]"
  echo ""
  echo "Options:"
  echo "  -H            Use full timestamp format (YYYYMMDDTHH:MM:SS)"
  echo "  -D            Use date-only format (YYYYMMDD)"
  echo "  -p <path>     Specify custom log directory (default: /var/log/apps)"
  echo "  -f <pattern>  File pattern to rotate (default: *.log)"
  echo "  -r <days>     Purge rotated logs older than <days>"
  echo "  -n            Dry-run mode (no changes made)"
  echo ""
  exit 1
}

if [ $# -eq 0 ]; then
  show_help
fi

while getopts "HDp:f:r:n" opt; do
  case "$opt" in
    H) DATE_SUFFIX=$(date +%Y%m%dT%H:%M:%S) ;;
    D) DATE_SUFFIX=$(date +%Y%m%d) ;;
    p) LOG_DIR="$OPTARG"; CUSTOM_PATH_USED=true ;;
    f) FILE_PATTERN="$OPTARG" ;;
    r) RETENTION_DAYS="$OPTARG" ;;
    n) DRY_RUN=true ;;
    *) show_help ;;
  esac
done

if $CUSTOM_PATH_USED && [ ! -d "$LOG_DIR" ]; then
  echo "Error: Custom log path '$LOG_DIR' does not exist."
  exit 1
fi

if [ -z "$DATE_SUFFIX" ]; then
  DATE_SUFFIX=$(date +%Y%m%d)
fi

LOG_FILES=$(find "$LOG_DIR" -type f -name "$FILE_PATTERN" -printf "%s %p\n" 2>/dev/null | sort -n | awk '{print $2}')

if [ -z "$LOG_FILES" ]; then
  echo "No files matching pattern '$FILE_PATTERN' found in $LOG_DIR"
  exit 0
fi

for LOG_FILE in $LOG_FILES; do
  if [ -f "$LOG_FILE" ] && [ -s "$LOG_FILE" ]; then
    ROTATED="${LOG_FILE}.${DATE_SUFFIX}"
    BACKUP_DIR="$(dirname "$LOG_FILE")/old_logs/$(date +%Y%m%d)"
    ARCHIVED_FILE="$BACKUP_DIR/$(basename "$LOG_FILE").${DATE_SUFFIX}.gz"

    if [ -f "$ARCHIVED_FILE" ]; then
      echo "$(date): Already rotated, skipping: $LOG_FILE"
      continue
    fi

    if $DRY_RUN; then
      ROTATED_basename=$(basename ${LOG_FILE})
      echo "[DRY-RUN] Would Rotate: ${LOG_FILE} -> $BACKUP_DIR/${ROTATED_basename}.gz"
    else
      cp "$LOG_FILE" "$ROTATED"
      > "$LOG_FILE"
      gzip "$ROTATED"
      mkdir -p "$BACKUP_DIR"
      mv "${ROTATED}.gz" "$BACKUP_DIR/"
      echo "$(date): Rotated: $LOG_FILE -> $ARCHIVED_FILE"
    fi
  else
    echo "$(date): Skipping empty or missing file: $LOG_FILE"
  fi

  if [ -n "$RETENTION_DAYS" ]; then
    PURGE_DIR="$(dirname "$LOG_FILE")/old_logs"
    if $DRY_RUN; then
      echo "[DRY-RUN] Would delete files older than $RETENTION_DAYS days in $PURGE_DIR"
    else
      find "$PURGE_DIR" -type f -name "*.gz" -mtime +$RETENTION_DAYS -exec rm -f {} \;
      echo "$(date): Purged logs older than $RETENTION_DAYS days in $PURGE_DIR"
    fi
  fi
done
