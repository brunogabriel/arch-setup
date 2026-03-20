#!/bin/bash

# terminal/github-copilot-cli.sh
# GitHub Copilot CLI assistant

install_github_copilot_cli() {
    log_info "Installing GitHub Copilot CLI..."

    gum style --foreground 81 "→ Downloading and installing GitHub Copilot CLI..."

    if curl -fsSL https://gh.io/copilot-install | bash; then
        gum style --foreground 48 "✓ GitHub Copilot CLI installed successfully"
        log_success "GitHub Copilot CLI installed successfully"
        return 0
    else
        gum style --foreground 196 "✗ Failed to install GitHub Copilot CLI"
        log_error "Failed to install GitHub Copilot CLI"
        return 1
    fi
}
