#!/bin/bash

# mise_installs/dotnet.sh
# .NET installation via mise

_dotnet_post_install() {
    smart_append_to_zsh "shell" \
        'export DOTNET_ROOT="$(mise where dotnet 2>/dev/null)"' \
        ".NET - DOTNET_ROOT"
}

install_dotnet() {
    mise_install_language \
        --name         ".NET" \
        --package      "dotnet" \
        --default      "latest" \
        --placeholder  "e.g., 8.0, 9.0" \
        --description  "latest installs the most recent stable .NET SDK" \
        --post-install "_dotnet_post_install" \
        --version-cmd  "dotnet --version"
}
