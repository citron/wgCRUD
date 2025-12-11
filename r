#!/bin/bash
# wgCRUD 'r' (read/view) - Display files in terminal based on MIME type

# Parse options
PAGE_RANGE=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        -p|--page)
            PAGE_RANGE="$2"
            shift 2
            ;;
        *)
            FILE="$1"
            shift
            ;;
    esac
done

if [ -z "$FILE" ]; then
    echo "Usage: r [-p|--page <range>] <file>"
    echo "  -p, --page    Page range for PDFs (e.g., 5, 5:7, :10, 10:)"
    exit 1
fi

if [ ! -f "$FILE" ]; then
    echo "Error: File '$FILE' not found"
    exit 1
fi

# Get MIME type and file extension
MIME=$(file --mime-type -b "$FILE")
EXT="${FILE##*.}"

case "$MIME" in
    image/*)
        # Use kitty icat for images
        if command -v kitty &> /dev/null; then
            kitty +kitten icat "$FILE"
        else
            echo "Error: kitty terminal required for image viewing"
            exit 1
        fi
        ;;
    video/*)
        # Use mpv to display video
        if command -v mpv &> /dev/null; then
            mpv --vo=kitty "$FILE"
        else
            echo "Error: mpv required for video viewing"
            exit 1
        fi
        ;;
    text/csv | text/tab-separated-values | application/vnd.ms-excel)
        # Use duckdb for CSV/TSV files
        if command -v duckdb &> /dev/null; then
            duckdb -c "SELECT * FROM '$FILE';"
        elif command -v bat &> /dev/null; then
            bat "$FILE"
        else
            cat "$FILE"
        fi
        ;;
    application/x-parquet | application/parquet)
        # Use duckdb for Parquet files
        if command -v duckdb &> /dev/null; then
            duckdb -c "SELECT * FROM '$FILE';"
        else
            echo "Error: duckdb required for Parquet viewing"
            exit 1
        fi
        ;;
    text/* | application/json | application/xml | application/javascript)
        # Check for data file extensions that might be detected as text/plain
        if [[ "$EXT" == "csv" || "$EXT" == "tsv" || "$EXT" == "parquet" ]]; then
            if command -v duckdb &> /dev/null; then
                duckdb -c "SELECT * FROM '$FILE';"
            elif command -v bat &> /dev/null; then
                bat "$FILE"
            else
                cat "$FILE"
            fi
        elif command -v bat &> /dev/null; then
            bat "$FILE"
        else
            cat "$FILE"
        fi
        ;;
    application/pdf)
        # Convert PDF pages to images and display
        if command -v pdftoppm &> /dev/null && command -v kitty &> /dev/null; then
            TEMP_DIR=$(mktemp -d)
            
            # Parse page range
            if [ -n "$PAGE_RANGE" ]; then
                if [[ "$PAGE_RANGE" =~ ^([0-9]*):([0-9]*)$ ]]; then
                    START="${BASH_REMATCH[1]:-1}"
                    END="${BASH_REMATCH[2]}"
                    if [ -z "$END" ]; then
                        pdftoppm -png -f "$START" "$FILE" "$TEMP_DIR/page" 2>/dev/null
                    else
                        pdftoppm -png -f "$START" -l "$END" "$FILE" "$TEMP_DIR/page" 2>/dev/null
                    fi
                elif [[ "$PAGE_RANGE" =~ ^[0-9]+$ ]]; then
                    pdftoppm -png -f "$PAGE_RANGE" -l "$PAGE_RANGE" "$FILE" "$TEMP_DIR/page" 2>/dev/null
                else
                    echo "Error: Invalid page range format. Use: 5, 5:7, :10, or 10:"
                    rm -rf "$TEMP_DIR"
                    exit 1
                fi
            else
                # Display all pages
                pdftoppm -png "$FILE" "$TEMP_DIR/page" 2>/dev/null
            fi
            
            # Display all generated images
            for img in "$TEMP_DIR"/*.png; do
                [ -f "$img" ] && kitty +kitten icat "$img"
            done
            
            rm -rf "$TEMP_DIR"
        else
            echo "Error: pdftoppm and kitty required for PDF viewing"
            exit 1
        fi
        ;;
    *)
        # Check for parquet files that may not be detected properly
        if [[ "$EXT" == "parquet" ]]; then
            if command -v duckdb &> /dev/null; then
                duckdb -c "SELECT * FROM '$FILE';"
            else
                echo "Error: duckdb required for Parquet viewing"
                exit 1
            fi
        elif [[ "$EXT" == "csv" || "$EXT" == "tsv" ]]; then
            if command -v duckdb &> /dev/null; then
                duckdb -c "SELECT * FROM '$FILE';"
            elif command -v bat &> /dev/null; then
                bat "$FILE"
            else
                cat "$FILE"
            fi
        else
            # Default to hex dump or basic info
            echo "MIME type: $MIME"
            if command -v hexyl &> /dev/null; then
                hexyl "$FILE" | head -n 20
            else
                xxd "$FILE" | head -n 20
            fi
        fi
        ;;
esac
