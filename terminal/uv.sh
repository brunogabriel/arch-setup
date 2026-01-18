#!/bin/bash

# terminal/uv.sh
# Fast Python package installer

install_uv() {
    log_info "Starting uv installation..."
    
    gum style --foreground 81 "→ Downloading and installing uv..."
    
    if curl -LsSf https://astral.sh/uv/install.sh | sh; then
        gum style --foreground 48 "✓ uv installed successfully"
        log_success "uv installed successfully"
        return 0
    else
        gum style --foreground 196 "✗ Failed to install uv"
        log_error "Failed to install uv"
        return 1
    fi
}
