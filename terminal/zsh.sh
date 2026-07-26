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
    
    # Set ZSH as default shell
    local current_shell=$(getent passwd "$USER" | cut -d: -f7)
    local zsh_path=$(which zsh)
    
    if [ "$current_shell" = "$zsh_path" ]; then
        log_info "ZSH is already the default shell"
        gum style --foreground 48 "✓ ZSH is already your default shell"
    else
        log_info "Setting ZSH as default shell..."
        if chsh -s "$zsh_path"; then
            log_success "ZSH set as default shell"
            gum style --foreground 48 "✓ ZSH is now your default shell"
        else
            log_warning "Failed to change default shell (may need sudo)"
            gum style --foreground 214 "⚠ Could not set ZSH as default. Run: chsh -s $zsh_path"
        fi
    fi
    
    log_info "ZSH installed successfully"
    
    return 0
}
