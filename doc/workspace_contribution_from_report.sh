#!/bin/bash

REPORT_FILE="/media/amin/storage/workspace/report/churn-report.log"

awk '
/^-- Per Author Summary --/ {
    in_author = 1
    next
}

/^-- Repository Summary --/ {
    in_author = 0
    next
}

in_author && /\|/ {
    # نمونه خط:
    # amin-amani | Added: 1337 | Deleted: 389 | Churn: 1726 | 56.74%

    author = $1

    for (i = 1; i <= NF; i++) {
        if ($i == "Added:")   add = $(i+1)
        if ($i == "Deleted:") del = $(i+1)
        if ($i == "Churn:")   churn = $(i+1)
    }

    a_add[author]   += add
    a_del[author]   += del
    a_churn[author] += churn

    total_add   += add
    total_del   += del
    total_churn += churn
}

END {
    print "=================================================="
    print "Workspace Contribution Summary (All Repositories)"
    print "=================================================="
    printf "%-15s | %-6s | %-7s | %-7s | %s\n", \
           "Author", "Added", "Deleted", "Churn", "% of Churn"
    print "--------------------------------------------------"

    for (a in a_churn) {
        pct = (total_churn > 0) ? (a_churn[a] * 100 / total_churn) : 0
        printf "%-15s | %-6d | %-7d | %-7d | %.2f%%\n", \
               a, a_add[a], a_del[a], a_churn[a], pct
    }

    print "--------------------------------------------------"
    printf "%-15s | %-6d | %-7d | %-7d | 100.00%%\n", \
           "TOTAL", total_add, total_del, total_churn
}
' "$REPORT_FILE"
