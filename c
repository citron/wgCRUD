#!/bin/bash
# wgCRUD 'c' (create) - Create new files

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

# Get file extension
EXT="${FILE##*.}"

# Check if it's an image file
if [[ "$EXT" =~ ^(png|jpg|jpeg|gif|bmp|tiff|webp)$ ]]; then
    if command -v convert &> /dev/null; then
        # Set default dimensions if not provided
        W="${WIDTH:-800}"
        H="${HEIGHT:-600}"
        
        # Create blank image with ImageMagick
        convert -size "${W}x${H}" xc:white "$FILE"
        echo "Created: $FILE (${W}x${H})"
    else
        echo "Error: ImageMagick (convert) required for image creation"
        exit 1
    fi
elif [ -n "$CONTENT" ]; then
    # Create file with provided content
    echo "$CONTENT" > "$FILE"
    echo "Created: $FILE"
else
    # Open in editor if no content provided
    ${EDITOR:-vi} "$FILE"
fi
