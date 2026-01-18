#!/bin/bash

# terminal/btop.sh
# Install and configure btop - Resource monitor

# Check if btop is already installed
is_btop_installed() {
    command -v btop &> /dev/null
}

# Install btop
install_btop() {
    log_info "Starting btop installation..."
    
    # Check if already installed
    if is_btop_installed; then
        gum style --foreground 75 "  btop is already installed"
        log_info "btop is already installed, applying theme..."
        
        # Apply theme even if already installed
        configure_btop
        
        return 0
    fi
    
    # Install btop via yay
    if yay -S --needed --noconfirm btop; then
        log_success "btop installed successfully"
        
        # Configure btop with theme
        configure_btop
        
        return 0
    else
        log_error "Failed to install btop"
        return 1
    fi
}

# Configure btop with theme
configure_btop() {
    local config_dir="$HOME/.config/btop"
    local themes_dir="$config_dir/themes"
    
    log_info "Configuring btop with theme..."
    
    # Create directories
    mkdir -p "$config_dir"
    mkdir -p "$themes_dir"
    
    # Apply theme using theme system
    if apply_theme_for_app "btop" "$config_dir"; then
        log_success "btop configured with $(get_current_theme) theme"
        return 0
    else
        log_warning "Failed to apply theme, using defaults"
        return 1
    fi
}

# Uninstall btop (for future use)
uninstall_btop() {
    if ! is_btop_installed; then
        gum style --foreground 214 "btop is not installed"
        return 0
    fi
    
    if yay -Rns --noconfirm btop; then
        gum style --foreground 48 "✓ btop uninstalled successfully"
        log_success "btop uninstalled successfully"
        return 0
    else
        gum style --foreground 196 "✗ Failed to uninstall btop"
        log_error "Failed to uninstall btop"
        return 1
    fi
}
