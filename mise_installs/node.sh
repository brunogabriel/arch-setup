#!/bin/bash

# mise_installs/node.sh
# Node.js installation via mise

_node_post_install() {
    # Expose where mise installed node and ensure it's discoverable in the shell
    smart_append_to_zsh "shell" \
        'export NODE_HOME="$(mise where node 2>/dev/null)"' \
        "Node.js - NODE_HOME"
}

install_node() {
    mise_install_language \
        --name         "Node.js" \
        --package      "node" \
        --default      "latest" \
        --placeholder  "e.g., 18.16.0, 20.0.0" \
        --description  "Installs the most recent stable Node.js runtime (latest)" \
        --post-install "_node_post_install" \
        --version-cmd  "node --version"
}
