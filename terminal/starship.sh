#!/bin/bash

# terminal/starship.sh
# Cross-shell prompt

install_starship() {
    log_info "Installing starship..."
    
    if ! yay_install "starship"; then
        return 1
    fi
    
    # Add starship activation to zsh
    smart_append_to_zsh "init" \
        'if command -v starship &> /dev/null; then
  eval "$(starship init zsh)"
fi' \
        "starship - Cross-shell prompt"
    
    return 0
}
