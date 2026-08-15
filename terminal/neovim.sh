#!/bin/bash

# terminal/neovim.sh
# Modern Vim-based text editor

install_neovim() {
    log_info "Installing neovim..."

    if ! pacman_install "neovim"; then
        return 1
    fi

    # Apply configuration
    log_info "Applying neovim configuration..."
    local config_dir="$HOME/.config/nvim"
    local config_source="$INSTALL_DIR/configs/nvim"

    if [ -d "$config_source" ]; then
        mkdir -p "$config_dir"
        cp -r "$config_source"/. "$config_dir/"
        log_success "Neovim configuration applied"
    else
        log_warning "Neovim config not found: $config_source"
    fi

    return 0
}
