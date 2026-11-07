#!/bin/bash

# desktop/herdr-app.sh
# Herdr app installer (desktop app; herdr CLI is installed separately)

install_herdr_app() {
    local herdr_app_home="${HERDR_APP_HOME:-${XDG_CONFIG_HOME:-$HOME/.config}/herdr-app}"
    local themes_dir="$herdr_app_home/themes"

    log_info "Starting Herdr app installation..."

    gum style --foreground 81 "→ Downloading and installing Herdr app..."

    # Installs the app into ~/.local/share/herdr-app with a launcher entry
    # and icon; "herdr-app" lands in ~/.local/bin. The official script also
    # installs herdr-core if there is none yet. Running it again updates the app.
    if curl -fsSL https://releases.herdr.dev/app/install.sh | sh; then
        gum style --foreground 48 "✓ Herdr app installed successfully"
        log_success "Herdr app installed successfully"

        # Ship the Tokyo Night Moon theme (as in themes/tokyo-night); the app
        # auto-discovers themes/*.json in its settings screen.
        mkdir -p "$themes_dir"
        if cp "$INSTALL_DIR/configs/herdr-app/themes/tokyonight-moon.json" "$themes_dir/"; then
            gum style --foreground 48 "✓ Herdr app Tokyo Night Moon theme installed"
            log_success "Herdr app theme installed"
        else
            log_warning "Failed to install Herdr app theme"
        fi

        if ! bash "$INSTALL_DIR/plugins/herdr-app/install.sh"; then
            gum style --foreground 196 "✗ Failed to install Arch Setup's Herdr App plugin"
            log_error "Failed to install Arch Setup's Herdr App plugin"
            return 1
        fi

        return 0
    else
        gum style --foreground 196 "✗ Failed to install Herdr app"
        log_error "Failed to install Herdr app"
        return 1
    fi
}
