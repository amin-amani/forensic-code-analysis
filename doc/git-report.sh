#!/bin/bash

BASE_DIR="/media/amin/storage/workspace"
REPORT_DIR="/media/amin/storage/workspace/report"
REPORT_FILE="$REPORT_DIR/report.log"

mkdir -p "$REPORT_DIR"
: > "$REPORT_FILE"   # پاک کردن محتوای قبلی فایل

for dir in "$BASE_DIR"/*; do
    if [ -d "$dir/.git" ]; then
        repo_name=$(basename "$dir")

        echo "========================================" >> "$REPORT_FILE"
        echo "Repository: $repo_name" >> "$REPORT_FILE"
        echo "========================================" >> "$REPORT_FILE"

        (
            cd "$dir" || exit
            git --no-pager log --since="2025-03-21"
        ) >> "$REPORT_FILE" 2>&1

        echo -e "\n\n" >> "$REPORT_FILE"
    fi
done

TP_LIST=$(grep -o 'TP-[0-9]\+' "$REPORT_FILE" | sort -u)

{
    echo
    echo "========================================"
    echo "TP SUMMARY"
    echo "========================================"
    echo "$TP_LIST"
} >> "$REPORT_FILE"

