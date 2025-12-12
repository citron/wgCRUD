#!/bin/bash
# CRUD.sh 'd' (delete) - Delete files with confirmation

# Source library
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
source "$SCRIPT_DIR/crudsh-lib.sh"

# Load config
load_config

if [ $# -eq 0 ]; then
    echo "Usage: d <file>"
    exit 1
fi

FILE="$1"

if [ ! -f "$FILE" ]; then
    echo "Error: File '$FILE' not found"
    exit 1
fi

read -p "Delete '$FILE'? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Get MIME type
    MIME=$(file --mime-type -b "$FILE")
    
    # Try to get command from config first
    if [ -n "$CRUDSH_CONFIG" ]; then
        CMD=$(get_command "$MIME" "d" "$FILE")
        if [ -n "$CMD" ]; then
            eval "$CMD"
            echo "Deleted: $FILE"
            exit 0
        fi
    fi
    
    # Fallback to rm
    rm "$FILE"
    echo "Deleted: $FILE"
else
    echo "Cancelled"
fi
