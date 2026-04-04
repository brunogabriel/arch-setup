#!/bin/bash

# mise_installs/bun.sh
# Bun installation via mise

_bun_post_install() {
    smart_append_to_zsh "shell" \
        'export BUN_INSTALL="$HOME/.local/share/bun"' \
        "Bun - BUN_INSTALL"
    smart_append_to_zsh "shell" \
        'export PATH="$BUN_INSTALL/bin:$PATH"' \
        "Bun - PATH"
}

install_bun() {
    mise_install_language \
        --name         "Bun" \
        --package      "bun" \
        --default      "latest" \
        --placeholder  "e.g., 1.0.0, 1.1.0" \
        --description  "Installs the most recent stable Bun runtime (latest)" \
        --post-install "_bun_post_install" \
        --version-cmd  "bun --version"
}