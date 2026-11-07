#!/bin/bash

# terminal/codex.sh
# OpenAI Codex CLI

install_codex() {
    log_info "Starting Codex CLI installation..."

    gum style --foreground 81 "→ Downloading and installing Codex CLI..."

    if curl -fsSL https://chatgpt.com/codex/install.sh | sh; then
        gum style --foreground 48 "✓ Codex CLI installed successfully"
        log_success "Codex CLI installed successfully"
        return 0
    else
        gum style --foreground 196 "✗ Failed to install Codex CLI"
        log_error "Failed to install Codex CLI"
        return 1
    fi
}
