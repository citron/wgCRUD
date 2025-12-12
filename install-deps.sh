#!/bin/bash
# CRUD.sh - Install Debian/Ubuntu dependencies

set -e

echo "=== CRUD.sh Dependency Installer ==="
echo

# Check if running as root or with sudo
if [ "$EUID" -ne 0 ]; then
    echo "This script requires sudo privileges."
    SUDO="sudo"
else
    SUDO=""
fi

# Required packages
REQUIRED_PACKAGES=(
    "file"              # MIME type detection
)

# Recommended packages
RECOMMENDED_PACKAGES=(
    "bat"               # Syntax highlighting for text files
    "mpv"               # Video player
    "poppler-utils"     # Provides pdftoppm for PDF viewing
    "hexyl"             # Better hex dumps
    "duckdb"            # CSV/TSV/Parquet viewer
    "imagemagick"       # Image creation and manipulation
)

echo "Required packages:"
for pkg in "${REQUIRED_PACKAGES[@]}"; do
    echo "  - $pkg"
done

echo
echo "Recommended packages:"
for pkg in "${RECOMMENDED_PACKAGES[@]}"; do
    echo "  - $pkg"
done

echo
echo "Note: Kitty terminal must be installed separately from:"
echo "  https://sw.kovidgoyal.net/kitty/"
echo

read -p "Install packages? (Y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    echo "Updating package lists..."
    $SUDO apt-get update
    
    echo
    echo "Installing packages..."
    $SUDO apt-get install -y "${REQUIRED_PACKAGES[@]}" "${RECOMMENDED_PACKAGES[@]}"
    
    echo
    echo "=== Installation complete! ==="
    echo
    echo "Checking installed versions:"
    for pkg in "${REQUIRED_PACKAGES[@]}" "${RECOMMENDED_PACKAGES[@]}"; do
        if dpkg -l | grep -q "^ii  $pkg"; then
            echo "  ✓ $pkg"
        else
            echo "  ✗ $pkg (not installed)"
        fi
    done
    
    echo
    echo "To use CRUD.sh, add to your PATH:"
    echo "  export PATH=\"\$PATH:$(pwd)\""
else
    echo "Installation cancelled."
fi
