#!/bin/bash

# terminal/herdr.sh
# Herdr - Development tool

install_herdr() {
    if command -v herdr &> /dev/null; then
        gum style --foreground 214 "⚠ Herdr is already installed"
        log_warning "Herdr is already installed"
        return 0
    fi

    log_info "Starting Herdr installation..."

    gum style --foreground 81 "→ Downloading and installing Herdr..."

    if curl -fsSL https://herdr.dev/install.sh | sh; then
        gum style --foreground 48 "✓ Herdr installed successfully"
        log_success "Herdr installed successfully"
        return 0
    else
        gum style --foreground 196 "✗ Failed to install Herdr"
        log_error "Failed to install Herdr"
        return 1
    fi
}
