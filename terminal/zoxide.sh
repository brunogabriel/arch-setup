#!/bin/bash

# terminal/zoxide.sh
# Smarter cd command

install_zoxide() {
    log_info "Installing zoxide..."
    
    if ! yay_install "zoxide"; then
        return 1
    fi
    
    # Add zoxide activation to zsh
    smart_append_to_zsh "init" \
        'if command -v zoxide &> /dev/null; then
  eval "$(zoxide init zsh)"
fi' \
        "zoxide - Smarter cd command"
    
    # Add cd alias to use zoxide
    smart_append_to_zsh "aliases" \
        "alias cd='z'" \
        "zoxide - Use 'z' for smart cd"
    
    return 0
}
