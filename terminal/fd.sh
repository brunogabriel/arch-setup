#!/bin/bash

# terminal/fd.sh
# Simple, fast alternative to find

install_fd() {
    log_info "Installing fd..."
    
    if ! yay_install "fd"; then
        return 1
    fi
    
    # Add fd alias to zsh if modular structure exists
    if check_zshrc_structure 2>/dev/null; then
        append_to_zsh_module "aliases" \
            "alias fd='fdfind'" \
            "fd - Fast alternative to find"
    fi
    
    return 0
}
