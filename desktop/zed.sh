#!/bin/bash

# desktop/zed.sh
# Zed editor installer (official repo package)

install_zed() {
    log_info "Installing Zed..."

    if ! pacman_install "zed"; then
        return 1
    fi

    # Ship the current user setup (Tokyo Night Moon theme, Material Icon
    # Theme, panel and font settings). Never overwrite an existing config.
    local config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/zed"
    local config_file="$config_dir/settings.json"

    mkdir -p "$config_dir"

    if [ -f "$config_file" ]; then
        gum style --foreground 214 "⚠ Existing Zed settings kept: $config_file"
        log_info "Zed settings already exist, not overwriting"
    elif cp "$INSTALL_DIR/configs/zed/settings.json" "$config_file"; then
        gum style --foreground 48 "✓ Zed settings installed (Tokyo Night Moon theme)"
        log_success "Zed settings installed"
    else
        gum style --foreground 196 "✗ Failed to install Zed settings"
        log_error "Failed to install Zed settings"
    fi

    # The theme and icon theme are extensions. `auto_install_extensions` in
    # settings.json makes Zed install them on startup, so no manual step.
    gum style --foreground 75 "  → Zed will auto-install the Tokyo Night and Material Icon Theme extensions"
    log_info "Zed auto-installs the tokyo-night and material-icon-theme extensions"

    return 0
}
