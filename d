#!/bin/bash
# wgCRUD 'd' (delete) - Delete files with confirmation

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
    rm "$FILE"
    echo "Deleted: $FILE"
else
    echo "Cancelled"
fi
