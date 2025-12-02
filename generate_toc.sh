#!/bin/bash

# Function to convert folder content to markdown table of contents
convert_folder_content_to_markdown_toc() {
    local base_folder="$1"
    local filetype_filter="$2"
    local level="${3:-0}"
    
    local nl=$'\n'
    local toc=""
    
    # Get directories, excluding specific ones
    local dirs=()
    while IFS= read -r -d '' dir; do
        local dirname=$(basename "$dir")
        if [[ ! "$dirname" =~ ^(.git|_site|pics|_posts|styles|_layouts)$ ]]; then
            dirs+=("$dir")
        fi
    done < <(find "$base_folder" -maxdepth 1 -mindepth 1 -type d -print0 | sort -z)
    
    for dir in "${dirs[@]}"; do
        # Check if ix.md exists in the current directory
        local ix_file="$dir/ix.md"
        local dir_name=$(basename "$dir")
        
        if [[ -f "$ix_file" ]]; then
            # If ix.md exists, create a link for the folder
            local relative_path="${dir#"$base_folder"/}"
            relative_path="${relative_path#/}"
            # Replace backslashes with forward slashes (for Windows compatibility)
            relative_path="${relative_path//\\//}"
            
            local suffix="https://mars9n9.github.io/cakes/$relative_path"
            suffix="${suffix%/}"
            
            # URL encode the path
            local encoded_suffix=$(echo "$suffix/ix.html" | sed -e 's/ /%20/g' -e 's/&/%26/g' -e 's/#/%23/g' -e 's/\[/%5B/g' -e 's/\]/%5D/g')
            
            # Add indentation
            for ((i=0; i<level; i++)); do
                toc+="  "
            done
            toc+="* [$dir_name]($encoded_suffix)$nl"
        else
            # If ix.md does not exist, show the folder name as plain text
            for ((i=0; i<level; i++)); do
                toc+="  "
            done
            toc+="* $dir_name$nl"
        fi
        
        # Recursively call the function for subfolders
        toc+=$(convert_folder_content_to_markdown_toc "$dir" "$filetype_filter" $((level + 1)))
        
        # Get markdown files in current directory, excluding ix.md
        local files=()
        while IFS= read -r -d '' file; do
            local filename=$(basename "$file")
            if [[ ! "$filename" == "ix.md" ]]; then
                files+=("$file")
            fi
        done < <(find "$dir" -maxdepth 1 -name "$filetype_filter" -type f -print0 2>/dev/null | sort -z)
        
        for file in "${files[@]}"; do
            local file_name=$(basename "$file")
            
            # Try to extract the title from the first line starting with '#'
            local title=""
            local first_line_with_hash=$(grep -m 1 "^#" "$file" 2>/dev/null || echo "")
            
            if [[ -n "$first_line_with_hash" ]]; then
                # Remove the '#' and any leading/trailing spaces
                title=$(echo "$first_line_with_hash" | sed -e 's/^#\s*//' -e 's/\s*$//')
            else
                # If no line starts with '#', default to the file name without extension
                title="${file_name%.*}"
            fi
            
            local relative_path="${dir#"$base_folder"/}"
            relative_path="${relative_path#/}"
            # Replace backslashes with forward slashes (for Windows compatibility)
            relative_path="${relative_path//\\//}"
            
            local suffix=""
            if [[ $level -eq 0 ]]; then
                suffix="https://mars9n9.github.io/cakes$relative_path"
            else
                suffix="https://mars9n9.github.io/cakes/$relative_path"
            fi
            suffix="${suffix%/}"
            
            # URL encode the path
            local encoded_url=$(echo "$suffix/$file_name" | sed -e 's/\.md$/.html/' -e 's/ /%20/g' -e 's/&/%26/g' -e 's/#/%23/g' -e 's/\[/%5B/g' -e 's/\]/%5D/g')
            
            # Add indentation
            for ((i=0; i<=level; i++)); do
                toc+="  "
            done
            toc+="* [$title]($encoded_url)$nl"
        done
    done
    
    echo "$toc"
}

# Main execution
current_directory=$(pwd)

# Check if directory exists
if [[ ! -d "$current_directory" ]]; then
    echo "Error: Directory '$current_directory' does not exist."
    exit 1
fi

# Convert folder content to markdown TOC
result=$(convert_folder_content_to_markdown_toc "$current_directory" "*.md")

# Write to file
echo "$result" > "$current_directory/index.markdown"

# Verify the file was created
if [[ -f "$current_directory/index.markdown" ]]; then
    echo "Successfully created index.markdown in $current_directory"
else
    echo "Error: Failed to create index.markdown"
    exit 1
fi
