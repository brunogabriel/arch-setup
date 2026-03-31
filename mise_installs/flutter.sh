#!/bin/bash

# mise_installs/flutter.sh
# Flutter SDK installation via mise

_flutter_post_install() {
    smart_append_to_zsh "shell" \
        'export PATH="$PATH":"$HOME/.pub-cache/bin"' \
        "Flutter - pub-cache binaries"
}

install_flutter() {
    log_info "Adding asdf-flutter plugin for up-to-date releases..."
    mise plugin add flutter https://github.com/oae/asdf-flutter 2>/dev/null || true

    mise_install_language \
        --name         "Flutter" \
        --package      "flutter" \
        --default      "latest" \
        --placeholder  "e.g., 3.16.0, stable, beta" \
        --post-install "_flutter_post_install" \
        --version-cmd  "flutter --version"
}
