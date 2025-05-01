#!/bin/bash

for cmd in curl jq unzip tree; do
    if ! command -v $cmd &> /dev/null; then
        echo "Error: $cmd is required but not installed."
        exit 1
    fi
done

usage() {
    echo "Usage: $0 github_url"
    echo "Example: $0 https://github.com/owner/repo/tree/branch/docs"
    exit 1
}

[ "$#" -ne 1 ] && usage

URL=$1
if [[ ! $URL =~ ^https://github\.com/([^/]+)/([^/]+)/tree/([^/]+)/(.+)$ ]]; then
    echo "Error: Invalid GitHub URL format"
    usage
fi

OWNER=${BASH_REMATCH[1]}
REPO=${BASH_REMATCH[2]}
BRANCH=${BASH_REMATCH[3]}
FOLDER_PATH=${BASH_REMATCH[4]}
SUBFOLDER_NAME=$(basename "$FOLDER_PATH")
OUTPUT_DIR="${OWNER}-${REPO}-${SUBFOLDER_NAME}"
COMBINED_MD="${OUTPUT_DIR}-combined.md"

TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

echo "Downloading $FOLDER_PATH from $OWNER/$REPO ($BRANCH branch)..."
curl -sL "https://api.github.com/repos/$OWNER/$REPO/zipball/$BRANCH" -o "$TEMP_DIR/repo.zip"

unzip -q "$TEMP_DIR/repo.zip" -d "$TEMP_DIR"
BASE_DIR=$(ls "$TEMP_DIR" | grep "$OWNER-$REPO")
SOURCE_DIR="$TEMP_DIR/$BASE_DIR/$FOLDER_PATH"

if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Folder $FOLDER_PATH not found in repository"
    exit 1
fi

mkdir -p "$OUTPUT_DIR"
cp -r "$SOURCE_DIR/." "./$OUTPUT_DIR/"

# Generate tree structure
echo "# ${OWNER}/${REPO}/${FOLDER_PATH}" > "$COMBINED_MD"
echo -e "\n## Repository Structure\n" >> "$COMBINED_MD"
echo '```' >> "$COMBINED_MD"
(cd "$OUTPUT_DIR" && tree -a) >> "$COMBINED_MD"
echo '```' >> "$COMBINED_MD"

echo -e "\n## Documentation Contents\n" >> "$COMBINED_MD"

# Find and combine markdown files
find "$OUTPUT_DIR" -type f \( -name "*.md" -o -name "*.mdx" \) | while read -r file; do
    rel_path=${file#"$OUTPUT_DIR/"}
    echo -e "\n-- $rel_path:\n" >> "$COMBINED_MD"
    echo '```markdown' >> "$COMBINED_MD"
    # Remove potential YAML frontmatter
    awk '
        BEGIN {front_matter=0; first_line=1}
        first_line && /^---$/ {front_matter=1; first_line=0; next}
        front_matter && /^---$/ {front_matter=0; next}
        !front_matter {print}
    ' "$file" >> "$COMBINED_MD"
    echo '```' >> "$COMBINED_MD"
done

echo "Successfully created $COMBINED_MD"
