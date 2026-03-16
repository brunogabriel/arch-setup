#!/bin/bash

# terminal/maestro.sh
# Maestro CLI - Mobile UI testing framework

install_maestro() {
    if command -v maestro &> /dev/null; then
        gum style --foreground 214 "⚠ Maestro CLI is already installed"
        log_warning "Maestro CLI is already installed"
        return 0
    fi

    log_info "Starting Maestro CLI installation..."

    gum style --foreground 81 "→ Downloading and installing Maestro CLI..."

    if curl -fsSL "https://get.maestro.mobile.dev" | bash; then
        gum style --foreground 48 "✓ Maestro CLI installed successfully"
        log_success "Maestro CLI installed successfully"
        return 0
    else
        gum style --foreground 196 "✗ Failed to install Maestro CLI"
        log_error "Failed to install Maestro CLI"
        return 1
    fi
}
