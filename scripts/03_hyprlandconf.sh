#!/usr/bin/env bash
set -euo pipefail

. "$(dirname "$0")/00_helpers.sh"

: "${TARGET_USER:?TARGET_USER must be set}"

UHOME="$(user_home "$TARGET_USER")"
CONFIG_DST="$UHOME/.config"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
CONFIG_SRC="$PROJECT_ROOT/.config"

THEMES_DST="$UHOME/.local/share/omadora/themes"
THEMES_SRC="$PROJECT_ROOT/themes"

timestamp() {
    date +%s
}

backup() {
    local path="$1"
    mv "$path" "$path.bak.$(timestamp)"
}

echo "Merging .config files"

[[ -d "$CONFIG_SRC" ]] || {
    echo "ERROR: $CONFIG_SRC not found"
    exit 1
}

find "$CONFIG_SRC" -type f | while read -r src; do
    rel="${src#$CONFIG_SRC/}"
    dst="$CONFIG_DST/$rel"

    echo "→ $rel"

    mkdir -p "$(dirname "$dst")"

    if [[ -f "$dst" && ! -L "$dst" ]]; then
        echo "Backup $dst"
        backup "$dst"
    fi

    ln -sfn "$src" "$dst"
    echo "Symlink $dst → $src"
done

echo ".config files merged successfully"

echo "Merging themes"

[[ -d "$THEMES_SRC" ]] || {
    echo "ERROR: $THEMES_SRC not found"
    exit 1
}

for theme_dir in "$THEMES_SRC"/*/; do
    theme_name="$(basename "$theme_dir")"
    dst_theme_dir="$THEMES_DST/$theme_name"

    echo "→ Theme: $theme_name"

    find "$theme_dir" -type f | while read -r src; do
        rel="${src#$theme_dir/}"
        dst="$dst_theme_dir/$rel"

        mkdir -p "$(dirname "$dst")"

        if [[ -f "$dst" && ! -L "$dst" ]]; then
            echo "  Backup $dst"
            backup "$dst"
        fi

        ln -sfn "$src" "$dst"
        echo "Symlink $dst → $src"
    done
done

echo "Themes merged successfully"
