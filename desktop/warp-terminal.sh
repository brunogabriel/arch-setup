#!/bin/bash

# desktop/warp-terminal.sh
# Warp terminal installer

install_warp_terminal() {
    log_info "Installing warp-terminal..."
    
    if ! yay_install "warp-terminal"; then
        return 1
    fi
    
    # Apply theme configuration
    log_info "Applying warp-terminal theme configuration..."
    local config_dir="$HOME/.warp/themes"
    local theme=$(get_current_theme)
    
    if apply_theme_for_app "warp-terminal" "$config_dir"; then
        log_success "Warp-terminal theme applied successfully"
    else
        log_warning "Failed to apply warp-terminal theme, using defaults"
    fi
    
    return 0
}
