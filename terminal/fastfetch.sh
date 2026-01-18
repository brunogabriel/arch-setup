#!/bin/bash

# terminal/fastfetch.sh
# Fast system information tool

install_fastfetch() {
    log_info "Installing fastfetch..."
    
    if ! yay_install "fastfetch"; then
        return 1
    fi
    
    # Apply configuration
    log_info "Applying fastfetch configuration..."
    local config_dir="$HOME/.config/fastfetch"
    local config_source="$INSTALL_DIR/configs/fastfetch/config.jsonc"
    
    if [ -f "$config_source" ]; then
        mkdir -p "$config_dir"
        cp "$config_source" "$config_dir/config.jsonc"
        log_success "Fastfetch configuration applied"
    else
        log_warning "Fastfetch config not found: $config_source"
    fi
    
    return 0
}
