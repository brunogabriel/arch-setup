#!/bin/bash

# desktop/ghostty.sh
# Ghostty terminal emulator installer

install_ghostty() {
    log_info "Installing ghostty..."
    
    if ! yay_install "ghostty"; then
        return 1
    fi
    
    # Apply theme configuration
    log_info "Applying ghostty theme configuration..."
    local config_dir="$HOME/.config/ghostty"
    local theme=$(get_current_theme)
    
    if apply_theme_for_app "ghostty" "$config_dir"; then
        log_success "Ghostty theme applied successfully"
    else
        log_warning "Failed to apply ghostty theme, using defaults"
    fi
    
    return 0
}
