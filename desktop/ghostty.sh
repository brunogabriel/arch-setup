#!/bin/bash

# desktop/ghostty.sh
# Ghostty terminal emulator installer

install_ghostty() {
    log_info "Installing ghostty..."
    
    if ! pacman_install "ghostty"; then
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
    
    # Replace desktop file with custom config (x11 backend + single instance)
    local desktop_file="$INSTALL_DIR/configs/ghostty/com.mitchellh.ghostty.desktop"
    local target="/usr/share/applications/com.mitchellh.ghostty.desktop"
    
    if [ -f "$desktop_file" ]; then
        log_info "Applying custom Ghostty desktop entry..."
        if sudo cp "$desktop_file" "$target"; then
            log_success "Ghostty desktop entry updated"
        else
            log_warning "Failed to update desktop entry (may need sudo)"
        fi
    fi
    
    return 0
}
