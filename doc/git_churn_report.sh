#!/bin/bash

BASE_DIR="/media/amin/storage/workspace"
REPORT_DIR="$BASE_DIR/report"
REPORT_FILE="$REPORT_DIR/churn-report.log"

mkdir -p "$REPORT_DIR"
: > "$REPORT_FILE"

for dir in "$BASE_DIR"/*; do
    if [ -d "$dir/.git" ]; then
        repo_name=$(basename "$dir")

        {
            echo "=================================================="
            echo "Repository: $repo_name"
            echo "=================================================="
        } >> "$REPORT_FILE"

        (
            cd "$dir" || exit

            # git log با exclude کردن lib/Unity
            git log \
                --since="2025-03-21" \
                --no-merges \
                --numstat \
                --pretty=format:"COMMIT %h %ad %an %s" \
                --date=short \
                -- . ':(exclude)lib/Unity' \
            | awk '
            BEGIN {
                repo_add=repo_del=0
            }

            /^COMMIT/ {
                if (commit != "") {
                    churn = add + del
                    printf "%s | Added: %d | Deleted: %d | Churn: %d\n", commit, add, del, churn

                    repo_add += add
                    repo_del += del

                    a_add[author] += add
                    a_del[author] += del
                }

                split(substr($0,8), f, " ")
                commit = substr($0,8)
                author = f[3]

                add=0
                del=0
                next
            }

            {
                add += $1
                del += $2
            }

            END {
                if (commit != "") {
                    churn = add + del
                    printf "%s | Added: %d | Deleted: %d | Churn: %d\n", commit, add, del, churn

                    repo_add += add
                    repo_del += del

                    a_add[author] += add
                    a_del[author] += del
                }

                repo_churn = repo_add + repo_del

                printf "\n-- Per Author Summary --\n"
                for (a in a_add) {
                    a_churn = a_add[a] + a_del[a]
                    pct = (repo_churn > 0) ? (a_churn * 100 / repo_churn) : 0
                    printf "%s | Added: %d | Deleted: %d | Churn: %d | %.2f%%\n",
                           a, a_add[a], a_del[a], a_churn, pct
                }

                printf "\n-- Repository Summary --\n"
                printf "Total Added:   %d\n", repo_add
                printf "Total Deleted: %d\n", repo_del
                printf "Total Churn:   %d\n", repo_churn
            }'
        ) >> "$REPORT_FILE" 2>&1

        echo -e "\n" >> "$REPORT_FILE"
    fi
done
