#!/bin/bash

# terminal/opencode.sh
# OpenCode AI coding assistant

install_opencode() {
    log_info "Starting OpenCode installation..."
    
    gum style --foreground 81 "→ Downloading and installing OpenCode..."
    
    if curl -fsSL https://opencode.ai/install | bash; then
        gum style --foreground 48 "✓ OpenCode installed successfully"
        log_success "OpenCode installed successfully"

        # Setup Moonlight theme
        log_info "Setting up OpenCode Moonlight theme..."
        mkdir -p "$HOME/.config/opencode/themes"
        if curl -fsSL -o "$HOME/.config/opencode/themes/moonlight.json" \
            "https://raw.githubusercontent.com/brunogabriel/opencode-moonlight-theme/main/.opencode/themes/moonlight.json"; then
            echo '{ "theme": "moonlight" }' > "$HOME/.config/opencode/opencode.json"
            gum style --foreground 48 "✓ Moonlight theme applied"
            log_success "Moonlight theme applied"
        else
            log_warning "Failed to download Moonlight theme"
        fi

        return 0
    else
        gum style --foreground 196 "✗ Failed to install OpenCode"
        log_error "Failed to install OpenCode"
        return 1
    fi
}
