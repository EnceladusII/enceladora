#!/usr/bin/env bash
set -euo pipefail

. "$(dirname "$0")/00_helpers.sh"

: "${TARGET_USER:?TARGET_USER must be set}"

UHOME="$(user_home "$TARGET_USER")"
CONFIG_DST="$UHOME/.config"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
CONFIG_SRC="$PROJECT_ROOT/.config"

timestamp() {
    date +%s
}

backup() {
    local path="$1"
    local ts
    ts="$(timestamp)"
    mv "$path" "$path.bak.$ts"
}

echo "Deploying .config"

[[ -d "$CONFIG_SRC" ]] || {
    echo "ERROR: $CONFIG_SRC not found"
    exit 1
}

mkdir -p "$CONFIG_DST"

for src in "$CONFIG_SRC"/*; do
    name="$(basename "$src")"
    dst="$CONFIG_DST/$name"

    if [[ -e "$dst" && ! -L "$dst" ]]; then
        echo "  Backup existing $dst"
        backup "$dst"
    fi

    ln -sfn "$src" "$dst"
done

echo ".config deployment complete"
