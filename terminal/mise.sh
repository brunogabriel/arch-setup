#!/bin/bash

# terminal/mise.sh
# Polyglot runtime manager

install_mise() {
    log_info "Installing mise..."
    
    if ! yay_install "mise"; then
        return 1
    fi
    
    # Add mise activation to zsh
    smart_append_to_zsh "init" \
        'if command -v mise &> /dev/null; then
  eval "$(mise activate zsh)"
fi' \
        "mise - Polyglot runtime manager"
    
    return 0
}
