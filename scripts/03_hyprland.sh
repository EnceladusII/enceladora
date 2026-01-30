#!/usr/bin/env bash
set -euo pipefail

. "$(dirname "$0")/00_helpers.sh"

# Setup the hyprland look and feel based on Omarchy configuration
: "${TARGET_USER:?TARGET_USER must be set}"
UHOME="$(user_home "$TARGET_USER")"

OMADORA_PATH=".local/share/omadora"
as_user "git clone --branch master https://github.com/elpritchos/omadora.git '$OMADORA_PATH'"
as_user "bash '$OMADORA_PATH/install.sh'"
