#!/bin/bash

# terminal/alacritty.sh
# Alacritty terminal emulator with Zellij as its default shell

install_alacritty() {
    log_info "Installing Alacritty..."

    if ! pacman_install "alacritty"; then
        return 1
    fi

    local config_dir="$HOME/.config/alacritty"
    mkdir -p "$config_dir"

    if [ ! -f "$config_dir/alacritty.toml" ]; then
        if ! cp "$INSTALL_DIR/configs/alacritty/alacritty.toml" "$config_dir/alacritty.toml"; then
            log_error "Failed to install Alacritty configuration"
            return 1
        fi
    fi

    if ! apply_theme_for_app "alacritty" "$config_dir"; then
        log_warning "Failed to apply Alacritty theme"
    fi

    return 0
}
