#!/bin/bash

# terminal/mise.sh
# Polyglot runtime manager

install_mise() {
    log_info "Installing mise..."
    
    if ! yay_install "mise"; then
        return 1
    fi
    
    # Add mise activation to zsh if modular structure exists
    if check_zshrc_structure 2>/dev/null; then
        append_to_zsh_module "init" \
            'if command -v mise &> /dev/null; then
  eval "$(mise activate zsh)"
fi' \
            "mise - Polyglot runtime manager"
    fi
    
    return 0
}
