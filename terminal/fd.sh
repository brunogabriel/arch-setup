#!/bin/bash

# terminal/fd.sh
# Simple, fast alternative to find

install_fd() {
    log_info "Installing fd..."
    
    if ! yay_install "fd"; then
        return 1
    fi
    
    # Add fd alias to zsh
    smart_append_to_zsh "aliases" \
        "alias fd='fdfind'" \
        "fd - Fast alternative to find"
    
    return 0
}
