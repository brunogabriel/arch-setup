#!/bin/bash

# terminal/starship.sh
# Cross-shell prompt

install_starship() {
    log_info "Installing starship..."
    
    if ! yay_install "starship"; then
        return 1
    fi
    
    # Add starship activation to zsh if modular structure exists
    if check_zshrc_structure 2>/dev/null; then
        append_to_zsh_module "init" \
            'if command -v starship &> /dev/null; then
  eval "$(starship init zsh)"
fi' \
            "starship - Cross-shell prompt"
    fi
    
    return 0
}
