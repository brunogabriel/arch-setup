#!/bin/bash

# desktop/kitty.sh
# Kitty terminal emulator installer

install_kitty() {
    log_info "Installing kitty..."
    
    if ! yay_install "kitty"; then
        return 1
    fi
    
    # Apply theme configuration
    log_info "Applying kitty theme configuration..."
    local config_dir="$HOME/.config/kitty"
    local theme=$(get_current_theme)
    
    if apply_theme_for_app "kitty" "$config_dir"; then
        log_success "Kitty theme applied successfully"
    else
        log_warning "Failed to apply kitty theme, using defaults"
    fi
    
    return 0
}
