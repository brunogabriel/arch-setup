#!/bin/bash

# mise_installs/flutter.sh
# Flutter SDK installation via mise

_flutter_post_install() {
    smart_append_to_zsh "shell" \
        'export PATH="$PATH":"$HOME/.pub-cache/bin"' \
        "Flutter - pub-cache binaries"
}

install_flutter() {
    mise_install_language \
        --name         "Flutter" \
        --package      "flutter" \
        --default      "latest" \
        --placeholder  "e.g., 3.16.0, stable, beta" \
        --post-install "_flutter_post_install" \
        --version-cmd  "flutter --version"
}
