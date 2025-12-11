# wgCRUD

CRUD-like aliases for terminal file operations with Kitty graphics protocol support.

## Commands

- **r** (read/view) - Display files using appropriate viewers based on MIME type
- **c** (create) - Create new files
- **u** (update) - Edit existing files
- **d** (delete) - Delete files with confirmation

## Installation

```bash
chmod +x c r u d wgcrud-lib.sh
# Add to PATH or create aliases:
export PATH="$PATH:/home/gacquewi/wgCRUD"

# Optional: Copy config to your home directory for customization
mkdir -p ~/.config/wgcrud
cp wgcrud.conf ~/.config/wgcrud/
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
c image.png             # Create 800x600 blank image
c -w 1920 -h 1080 image.png  # Create custom size image
c -w 500 photo.jpg      # Create 500x600 image (default height)
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
  - `imagemagick` (image creation)
- **Optional editors** (for 'u' command):
  - `gimp` or `krita` (image editing)
  - `kdenlive` or `openshot` (video editing)
  - `xournalpp` or `okular` (PDF annotation)
  - `libreoffice` (CSV/spreadsheet editing)

## Configuration

wgCRUD uses a configuration file to map MIME types to tools for each action. The config file is searched in the following locations (in order):

1. `~/.config/wgcrud/wgcrud.conf`
2. `~/.wgcrud.conf`
3. `<install-dir>/wgcrud.conf`
4. `/etc/wgcrud.conf`

### Config Format

```ini
# Format: MIME_TYPE:ACTION=COMMAND
# Actions: c (create), r (read), u (update), d (delete)
# Placeholders: {file}, {width}, {height}, {pages}, {temp}

image/*:r=kitty +kitten icat {file}
image/*:u=gimp {file}
text/csv:r=duckdb -c "SELECT * FROM '{file}';"
```

### Customization Example

```bash
# Copy default config
mkdir -p ~/.config/wgcrud
cp wgcrud.conf ~/.config/wgcrud/

# Edit to use your preferred tools
# For example, change image editor from gimp to krita:
# image/*:u=krita {file}

# Or use Inkscape for vector images:
# image/svg+xml:u=inkscape {file}

# Use LibreOffice for CSV files:
# text/csv:u=libreoffice --calc {file}
```

### Suggested Tools by Category

**Images:**
- GUI: `gimp`, `krita`, `inkscape`, `kolourpaint`, `pinta`
- CLI: `imagemagick display`

**Videos:**
- `kdenlive`, `openshot`, `shotcut`, `davinci-resolve`, `blender`

**PDFs:**
- Annotate: `xournalpp`, `okular`, `evince`
- Edit: `libreoffice --draw`, `inkscape`, `pdfarranger`

**CSV/Tabular:**
- Spreadsheet: `libreoffice --calc`, `gnumeric`
- Terminal: `sc-im`, `visidata`

## License

MIT
