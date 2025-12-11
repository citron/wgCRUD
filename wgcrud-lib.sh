#!/bin/bash
# wgCRUD Library - Common functions for loading and using config

# Config file locations (checked in order)
CONFIG_LOCATIONS=(
    "$HOME/.config/wgcrud/wgcrud.conf"
    "$HOME/.wgcrud.conf"
    "$(dirname "${BASH_SOURCE[0]}")/wgcrud.conf"
    "/etc/wgcrud.conf"
)

# Find and source config file
load_config() {
    for config in "${CONFIG_LOCATIONS[@]}"; do
        if [ -f "$config" ]; then
            WGCRUD_CONFIG="$config"
            return 0
        fi
    done
    echo "Warning: No config file found" >&2
    return 1
}

# Get command for a MIME type and action
# Usage: get_command "image/png" "r" "/path/to/file"
get_command() {
    local mime="$1"
    local action="$2"
    local file="$3"
    local width="${4:-800}"
    local height="${5:-600}"
    local pages="${6:-}"
    local temp="${7:-}"
    
    if [ -z "$WGCRUD_CONFIG" ]; then
        return 1
    fi
    
    # Try exact match first
    local cmd=$(grep -E "^${mime}:${action}=" "$WGCRUD_CONFIG" | head -n1 | cut -d= -f2-)
    
    # Try wildcard match (e.g., image/*)
    if [ -z "$cmd" ]; then
        local mime_prefix="${mime%%/*}"
        cmd=$(grep -E "^${mime_prefix}/\*:${action}=" "$WGCRUD_CONFIG" | head -n1 | cut -d= -f2-)
    fi
    
    # Try default fallback (*)
    if [ -z "$cmd" ]; then
        cmd=$(grep -E "^\*:${action}=" "$WGCRUD_CONFIG" | head -n1 | cut -d= -f2-)
    fi
    
    # Return empty if no command found or command is empty
    if [ -z "$cmd" ]; then
        return 1
    fi
    
    # Replace placeholders
    cmd="${cmd//\{file\}/$file}"
    cmd="${cmd//\{width\}/$width}"
    cmd="${cmd//\{height\}/$height}"
    cmd="${cmd//\{pages\}/$pages}"
    cmd="${cmd//\{temp\}/$temp}"
    
    echo "$cmd"
    return 0
}

# Check if a command is available in config
has_command() {
    local mime="$1"
    local action="$2"
    
    local cmd=$(get_command "$mime" "$action" "dummy")
    [ -n "$cmd" ] && return 0 || return 1
}

# Execute command from config
exec_command() {
    local cmd="$1"
    eval "$cmd"
}
