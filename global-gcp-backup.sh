#!/bin/bash

# Usage: ./global-gcp-backup.sh --source <path> --destination <gs://bucket> --days <N>

set -e

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --source)
      SRC="$2"
      shift 2
      ;;
    --destination)
      DST="$2"
      shift 2
      ;;
    --days)
      DAYS="$2"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1"
      exit 1
      ;;
  esac
done

if [[ -z "$SRC" || -z "$DST" || -z "$DAYS" ]]; then
  echo "Usage: $0 --source <path> --destination <gs://bucket> --days <N>"
  exit 1
fi

DST="${DST%/}"
HOSTNAME=$(hostname)

# Calculate cutoff date
CUTOFF_YMD=$(date -d "-$DAYS day" +%Y%m%d)
CUTOFF_YMD_DASH=$(date -d "-$DAYS day" +%Y-%m-%d)

# Find all files with a date in the name
find "$SRC" -type f -print0 | while IFS= read -r -d '' file; do
  BASENAME=$(basename "$file")
  # Extract YYYYMMDD or YYYY-MM-DD from filename
  if [[ $BASENAME =~ ([0-9]{8}) ]]; then
    FILE_DATE=${BASENAME:${BASH_REMATCH[0]}}
    FILE_DATE=${BASH_REMATCH[1]}
    # Compare as YYYYMMDD
    if [[ $FILE_DATE < $CUTOFF_YMD ]]; then
      MOVE=1
    else
      MOVE=0
    fi
  elif [[ $BASENAME =~ ([0-9]{4}-[0-9]{2}-[0-9]{2}) ]]; then
    FILE_DATE=${BASH_REMATCH[1]}
    # Compare as YYYY-MM-DD
    if [[ $FILE_DATE < $CUTOFF_YMD_DASH ]]; then
      MOVE=1
    else
      MOVE=0
    fi
  else
    MOVE=0
  fi
  if [[ $MOVE -eq 1 ]]; then
    DIR=$(dirname "$file")
    RELDIR="${DIR#/}"
    DEST_PATH="$DST/$HOSTNAME/$RELDIR/"
    echo "Moving $file to $DEST_PATH"
    gsutil mv "$file" "$DEST_PATH"
  fi
done 