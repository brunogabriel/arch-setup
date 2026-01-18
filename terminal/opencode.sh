#!/bin/bash

# terminal/opencode.sh
# OpenCode AI coding assistant

install_opencode() {
    log_info "Starting OpenCode installation..."
    
    gum style --foreground 81 "→ Downloading and installing OpenCode..."
    
    if curl -fsSL https://opencode.ai/install | bash; then
        gum style --foreground 48 "✓ OpenCode installed successfully"
        log_success "OpenCode installed successfully"
        return 0
    else
        gum style --foreground 196 "✗ Failed to install OpenCode"
        log_error "Failed to install OpenCode"
        return 1
    fi
}
