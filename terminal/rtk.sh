#!/bin/bash

# terminal/rtk.sh
# RTK - AI-powered terminal assistant

install_rtk() {
    log_info "Starting RTK installation..."

    gum style --foreground 81 "→ Downloading and installing RTK..."

    if curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh; then
        gum style --foreground 48 "✓ RTK installed successfully"
        log_success "RTK installed successfully"
        return 0
    else
        gum style --foreground 196 "✗ Failed to install RTK"
        log_error "Failed to install RTK"
        return 1
    fi
}
