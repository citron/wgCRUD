#!/bin/bash
# CRUD.sh 'c' (create) - Create new files

# Source library
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
source "$SCRIPT_DIR/crudsh-lib.sh"

# Load config
load_config

# Parse options
WIDTH=""
HEIGHT=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        -w|--width)
            WIDTH="$2"
            shift 2
            ;;
        -h|--height)
            HEIGHT="$2"
            shift 2
            ;;
        *)
            if [ -z "$FILE" ]; then
                FILE="$1"
            else
                CONTENT="$@"
            fi
            shift
            ;;
    esac
done

if [ -z "$FILE" ]; then
    echo "Usage: c [-w|--width <pixels>] [-h|--height <pixels>] <file> [content]"
    echo "  For images: c -w 800 -h 600 image.png"
    echo "  For text: c file.txt 'content'"
    exit 1
fi

if [ -f "$FILE" ]; then
    echo "Error: File '$FILE' already exists"
    exit 1
fi

# Get file extension and determine MIME type
EXT="${FILE##*.}"
MIME="text/plain"

# Determine MIME type from extension
case "$EXT" in
    png|jpg|jpeg|gif|bmp|tiff|webp)
        MIME="image/$EXT"
        ;;
    csv) MIME="text/csv" ;;
    tsv) MIME="text/tab-separated-values" ;;
    parquet) MIME="application/parquet" ;;
    pdf) MIME="application/pdf" ;;
    json) MIME="application/json" ;;
    xml) MIME="application/xml" ;;
    js) MIME="application/javascript" ;;
esac

# Set default dimensions for images
W="${WIDTH:-800}"
H="${HEIGHT:-600}"

# Try to get command from config first
if [ -n "$CRUDSH_CONFIG" ]; then
    CMD=$(get_command "$MIME" "c" "$FILE" "$W" "$H")
    if [ -n "$CMD" ]; then
        eval "$CMD"
        echo "Created: $FILE"
        exit 0
    fi
fi

# Fallback to built-in logic
if [[ "$EXT" =~ ^(png|jpg|jpeg|gif|bmp|tiff|webp)$ ]]; then
    if command -v convert &> /dev/null; then
        convert -size "${W}x${H}" xc:white "$FILE"
        echo "Created: $FILE (${W}x${H})"
    else
        echo "Error: ImageMagick (convert) required for image creation"
        exit 1
    fi
elif [ -n "$CONTENT" ]; then
    echo "$CONTENT" > "$FILE"
    echo "Created: $FILE"
else
    ${EDITOR:-vi} "$FILE"
fi
