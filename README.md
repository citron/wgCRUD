# wgCRUD

CRUD-like aliases for terminal file operations with Kitty graphics protocol support.

## Commands

- **r** (read/view) - Display files using appropriate viewers based on MIME type
- **c** (create) - Create new files
- **u** (update) - Edit existing files
- **d** (delete) - Delete files with confirmation

## Installation

```bash
chmod +x c r u d
# Add to PATH or create aliases:
export PATH="$PATH:/home/gacquewi/wgCRUD"
```

## Usage

### Read/View (r)
```bash
r image.png      # Display image in terminal
r video.mp4      # Play video
r document.txt   # Display text file
r data.pdf       # Display all PDF pages
r -p 5 data.pdf  # Display page 5 only
r -p 5:7 data.pdf # Display pages 5 to 7
r -p :10 data.pdf # Display pages 1 to 10
r -p 10: data.pdf # Display from page 10 to end
```

Supported MIME types:
- **Images** (image/*) - via `kitty +kitten icat`
- **Videos** (video/*) - via `mpv`
- **Data files** (CSV/TSV/Parquet) - via `duckdb`
- **Text files** - via `bat` or `cat`
- **PDFs** - via `pdftoppm`
- **Other** - hex dump view

### Create (c)
```bash
c newfile.txt           # Open in editor
c newfile.txt "content" # Create with content
```

### Update (u)
```bash
u existing.txt   # Edit in $EDITOR
```

### Delete (d)
```bash
d oldfile.txt    # Delete with confirmation
```

## Dependencies

- **Required**: `file` (MIME detection)
- **Recommended**:
  - `kitty` terminal (for image display)
  - `bat` (syntax highlighting for text)
  - `mpv` (video player)
  - `duckdb` (CSV/TSV/Parquet viewer)
  - `pdftoppm` (PDF viewing)
  - `hexyl` (better hex dumps)

## License

MIT
