#!/bin/bash

# terminal/zsh.sh
# Z Shell with modular configuration system

install_zsh() {
    log_info "Installing ZSH..."
    
    # Install zsh
    if ! yay_install "zsh"; then
        return 1
    fi
    
    # Install zsh plugins
    if ! install_zsh_plugins; then
        log_warning "ZSH plugins installation failed, continuing..."
    fi
    
    # Setup modular configuration
    if ! setup_zsh_config; then
        log_error "Failed to setup ZSH configuration"
        return 1
    fi
    
    # Prompt to change default shell
    log_info "ZSH installed successfully"
    echo ""
    gum style --foreground 81 "To set ZSH as your default shell, run:"
    gum style --foreground 75 "  chsh -s \$(which zsh)"
    echo ""
    
    return 0
}
