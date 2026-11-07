#!/bin/bash

# terminal/zellij.sh
# Zellij terminal workspace

install_zellij() {
    log_info "Installing Zellij..."

    if ! pacman_install "zellij"; then
        return 1
    fi

    local config_dir="$HOME/.config/zellij"
    mkdir -p "$config_dir/themes"

    if [ ! -f "$config_dir/config.kdl" ]; then
        if ! cp "$INSTALL_DIR/configs/zellij/config.kdl" "$config_dir/config.kdl"; then
            log_error "Failed to install Zellij configuration"
            return 1
        fi
    fi

    if ! cp "$INSTALL_DIR/themes/tokyo-night/zellij/tokyonight_moon.kdl" "$config_dir/themes/tokyonight_moon.kdl"; then
        log_warning "Failed to install Tokyo Night Moon theme for Zellij"
    fi

    return 0
}
