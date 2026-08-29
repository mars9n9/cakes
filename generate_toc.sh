#!/usr/bin/env bash
set -euo pipefail

BASE_URL="https://mars9n9.github.io/cakes"
ROOT="${1:-$PWD}"

url_encode() {
    local value="${1}"
    value=${value// /%20}
    value=${value//&/%26}
    value=${value//#/%23}
    value=${value//\[/%5B}
    value=${value//\]/%5D}
    printf '%s' "$value"
}

page_title() {
    local file="$1"
    local title
    local name
    title=$(awk '
        BEGIN { found = 0 }
        /^# / && found == 0 {
            sub(/^# +/, "", $0)
            sub(/[[:space:]]+$/, "", $0)
            print
            found = 1
            exit
        }
    ' "$file")

    if [[ -n "$title" ]]; then
        printf '%s' "$title"
    else
        name="${file##*/}"
        printf '%s' "${name%.md}"
    fi
}

build_url() {
    local relative_path="$1"
    local encoded
    encoded=$(url_encode "$relative_path")
    printf '%s/%s' "$BASE_URL" "$encoded"
}

walk_dir() {
    local dir="$1"
    local level="${2:-0}"
    local indent=""
    local file_indent=""
    local i
    local dir_name
    local rel_path
    local href
    local child
    local file
    local title
    local file_rel

    for ((i = 0; i < level; i++)); do
        indent+="  "
    done
    for ((i = 0; i <= level; i++)); do
        file_indent+="  "
    done

    dir_name=$(basename "$dir")
    rel_path="${dir#"$ROOT"/}"
    if [[ "$rel_path" == "$dir" ]]; then
        rel_path=""
    fi

    if [[ -f "$dir/ix.md" ]]; then
        href="$BASE_URL"
        if [[ -n "$rel_path" ]]; then
            href+="/$(url_encode "$rel_path")"
        fi
        href="${href%/}/ix.html"
        printf '%s* [%s](%s)\n' "$indent" "$dir_name" "$href"
    elif [[ -n "$rel_path" ]]; then
        printf '%s* %s\n' "$indent" "$dir_name"
    fi

    while IFS= read -r -d '' child; do
        child_name=$(basename "$child")
        if [[ "$child_name" =~ ^(\.git|\.github|_site|pics|_posts|styles|_layouts)$ ]]; then
            continue
        fi
        if [[ -d "$child" ]]; then
            walk_dir "$child" $((level + 1))
        fi
    done < <(find "$dir" -mindepth 1 -maxdepth 1 -print0 | sort -z)

    while IFS= read -r -d '' file; do
        file_name=$(basename "$file")
        if [[ "$file_name" == "ix.md" ]]; then
            continue
        fi
        title=$(page_title "$file")
        file_rel="${file#"$ROOT"/}"
        href=$(build_url "${file_rel%.md}.html")
        printf '%s* [%s](%s)\n' "$file_indent" "$title" "$href"
    done < <(find "$dir" -mindepth 1 -maxdepth 1 -type f -name '*.md' -print0 | sort -z)
}

if [[ ! -d "$ROOT" ]]; then
    echo "Error: Directory '$ROOT' does not exist." >&2
    exit 1
fi

printf '' > "$ROOT/index.markdown"

while IFS= read -r -d '' dir; do
    dir_name=$(basename "$dir")
    if [[ "$dir_name" =~ ^(\.git|\.github|_site|pics|_posts|styles|_layouts)$ ]]; then
        continue
    fi
    walk_dir "$dir" 0 >> "$ROOT/index.markdown"
    printf '\n' >> "$ROOT/index.markdown"
done < <(find "$ROOT" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)

if [[ -f "$ROOT/index.markdown" ]]; then
    echo "Successfully created index.markdown in $ROOT"
    echo "Output preview (first 30 lines):"
    echo "--------------------------------"
    head -30 "$ROOT/index.markdown"
    echo "--------------------------------"
else
    echo "Error: Failed to create index.markdown" >&2
    exit 1
fi