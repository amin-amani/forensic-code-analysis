#!/bin/bash

set -e

# ---------------- CONFIG ----------------
since_date="2000-03-21"
output_file="code_quality_history.csv"
SRC_DIR="src"
# ----------------------------------------

echo "commit,date,author,code_lines,comment_lines,blank_lines,max_complexity,avg_complexity,cppcheck_warnings,cppcheck_errors,clang_warnings,clang_errors" \
> "$output_file"

# save current branch
current_ref=$(git rev-parse --abbrev-ref HEAD)

# ✅ همه commitها (نه فقط HEAD)
commits=$(git rev-list --reverse --all --date-order)

for commit in $commits; do
    echo "Processing $commit ..."

    if ! git checkout -q "$commit"; then
        echo "Checkout failed"
        continue
    fi

    short_commit=$(git rev-parse --short=7 "$commit")
    author=$(git show -s --format='%an' "$commit")
    date=$(git show -s --format='%ad' --date=short "$commit")

    files=$(find "$SRC_DIR" \
        -type f \( -name "*.c" -o -name "*.cpp" -o -name "*.h" -o -name "*.hpp" \) 2>/dev/null)

    # اگر سورس نبود commit را صفر ثبت کن
    if [ -z "$files" ]; then
        echo "$short_commit,$date,$author,0,0,0,0,0,0,0,0,0" >> "$output_file"
        continue
    fi

    # ---------------- 1. CLOC ----------------
    cloc_output=$(echo "$files" | xargs cloc --csv --quiet --sum-one 2>/dev/null | tail -n 1)

    blank_lines=$(echo "$cloc_output" | cut -d',' -f3)
    comment_lines=$(echo "$cloc_output" | cut -d',' -f4)
    code_lines=$(echo "$cloc_output" | cut -d',' -f5)

    blank_lines=${blank_lines:-0}
    comment_lines=${comment_lines:-0}
    code_lines=${code_lines:-0}

    # ---------------- 2. COMPLEXITY (LIZARD) ----------------
    # CCN = Cyclomatic Complexity Number

    lizard_output=$(lizard "$SRC_DIR" 2>/dev/null || true)

    complexity_values=$(echo "$lizard_output" \
        | awk '/^[ ]*[0-9]+/ {print $2}')

    if [ -z "$complexity_values" ]; then
        max_complexity=0
        avg_complexity=0
    else
        max_complexity=$(echo "$complexity_values" | sort -nr | head -1)
        avg_complexity=$(echo "$complexity_values" \
            | awk '{s+=$1;c++} END{printf "%.2f", s/c}')
    fi

    # ---------------- 3. CPPCHECK ----------------
    cpp_output=$(cppcheck --enable=all "$SRC_DIR" 2>&1 || true)

    cppcheck_warnings=$(echo "$cpp_output" | grep -ci warning || true)
    cppcheck_errors=$(echo "$cpp_output" | grep -ci error || true)

    # ---------------- 4. CLANG-TIDY ----------------
    clang_output=$(echo "$files" | xargs clang-tidy 2>/dev/null || true)

    clang_warnings=$(echo "$clang_output" | grep -ci "warning:" || true)
    clang_errors=$(echo "$clang_output" | grep -ci "error:" || true)

    # ---------------- CSV ----------------
    echo "$short_commit,$date,$author,$code_lines,$comment_lines,$blank_lines,$max_complexity,$avg_complexity,$cppcheck_warnings,$cppcheck_errors,$clang_warnings,$clang_errors" \
    >> "$output_file"

done

git checkout -q "$current_ref"

echo "✔ Done → $output_file"
