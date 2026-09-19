#!/bin/bash

# terminal/pi-coding.sh
# Pi coding agent

install_pi_coding() {
    log_info "Installing Pi coding agent..."

    if ! command -v npm &> /dev/null; then
        gum style --foreground 196 "✗ npm is not installed"
        log_error "Failed to install Pi coding agent: npm is not installed"
        return 1
    fi

    gum style --foreground 81 "→ Installing Pi coding agent..."

    if npm install -g --ignore-scripts @earendil-works/pi-coding-agent; then
        gum style --foreground 48 "✓ Pi coding agent installed successfully"
        log_success "Pi coding agent installed successfully"
        return 0
    else
        gum style --foreground 196 "✗ Failed to install Pi coding agent"
        log_error "Failed to install Pi coding agent"
        return 1
    fi
}
