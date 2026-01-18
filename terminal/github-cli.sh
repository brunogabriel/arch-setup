#!/bin/bash

# terminal/github-cli.sh
# GitHub CLI tool

install_github_cli() {
    log_info "Installing GitHub CLI..."
    
    if ! yay_install "github-cli"; then
        return 1
    fi
    
    # Add git utility aliases to zsh if modular structure exists
    if check_zshrc_structure 2>/dev/null; then
        append_to_zsh_module "aliases" \
            "alias gdel='git branch | grep -v \"main\" | xargs git branch -D'" \
            "git - Delete all branches except main"
    fi
    
    return 0
}
