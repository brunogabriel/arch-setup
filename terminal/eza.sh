#!/bin/bash

# terminal/eza.sh
# Modern replacement for ls

install_eza() {
    log_info "Installing eza..."
    
    if ! yay_install "eza"; then
        return 1
    fi
    
    # Add eza aliases to zsh
    smart_append_to_zsh "aliases" \
        "alias ls='eza -lh --group-directories-first --icons'
alias lsa='ls -a'
alias lt='eza --tree --level=2 --long --icons --git'
alias lta='lt -a'" \
        "eza - Modern ls replacement"
    
    return 0
}
