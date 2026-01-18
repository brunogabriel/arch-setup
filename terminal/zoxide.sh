#!/bin/bash

# terminal/zoxide.sh
# Smarter cd command

install_zoxide() {
    log_info "Installing zoxide..."
    
    if ! yay_install "zoxide"; then
        return 1
    fi
    
    # Add zoxide activation to zsh if modular structure exists
    if check_zshrc_structure 2>/dev/null; then
        append_to_zsh_module "init" \
            'if command -v zoxide &> /dev/null; then
  eval "$(zoxide init zsh)"
fi' \
            "zoxide - Smarter cd command"
        
        # Add cd alias to use zoxide
        append_to_zsh_module "aliases" \
            "alias cd='z'" \
            "zoxide - Use 'z' for smart cd"
    fi
    
    return 0
}
