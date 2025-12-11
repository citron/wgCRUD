#!/bin/bash
# wgCRUD 'c' (create) - Create new files

if [ $# -eq 0 ]; then
    echo "Usage: c <file> [content]"
    exit 1
fi

FILE="$1"
shift

if [ -f "$FILE" ]; then
    echo "Error: File '$FILE' already exists"
    exit 1
fi

if [ $# -eq 0 ]; then
    # Open in editor if no content provided
    ${EDITOR:-vi} "$FILE"
else
    # Create file with provided content
    echo "$@" > "$FILE"
    echo "Created: $FILE"
fi
