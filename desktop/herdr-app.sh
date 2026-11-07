#!/bin/bash

# desktop/herdr-app.sh
# Herdr app installer (desktop app; herdr CLI is installed separately)

install_herdr_app() {
    log_info "Starting Herdr app installation..."

    gum style --foreground 81 "→ Downloading and installing Herdr app..."

    # Installs the app into ~/.local/share/herdr-app with a launcher entry
    # and icon; "herdr-app" lands in ~/.local/bin. The official script also
    # installs herdr-core if there is none yet. Running it again updates the app.
    if curl -fsSL https://releases.herdr.dev/app/install.sh | sh; then
        gum style --foreground 48 "✓ Herdr app installed successfully"
        log_success "Herdr app installed successfully"
        return 0
    else
        gum style --foreground 196 "✗ Failed to install Herdr app"
        log_error "Failed to install Herdr app"
        return 1
    fi
}
