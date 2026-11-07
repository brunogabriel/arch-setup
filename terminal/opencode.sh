#!/bin/bash

# terminal/opencode.sh
# OpenCode AI coding assistant

install_opencode() {
    log_info "Starting OpenCode installation..."
    
    gum style --foreground 81 "→ Downloading and installing OpenCode..."
    
    if curl -fsSL https://opencode.ai/install | bash; then
        gum style --foreground 48 "✓ OpenCode installed successfully"
        log_success "OpenCode installed successfully"

        # Setup Tokyo Night Moon theme (official folke/tokyonight.nvim extras)
        log_info "Setting up OpenCode Tokyo Night Moon theme..."
        mkdir -p "$HOME/.config/opencode/themes"
        if curl -fsSL -o "$HOME/.config/opencode/themes/tokyonight_moon.json" \
            "https://raw.githubusercontent.com/folke/tokyonight.nvim/main/extras/opencode/tokyonight_moon.json"; then
            # OpenCode keeps the TUI theme setting in tui.json; create or
            # merge without touching the other keys
            python3 - "$HOME/.config/opencode/tui.json" <<'PY' || log_warning "Failed to update tui.json with the theme"
import json, sys

path = sys.argv[1]
data = {}

try:
    with open(path) as f:
        data = json.load(f)
except FileNotFoundError:
    pass

data["theme"] = "tokyonight_moon"

with open(path, "w") as f:
    json.dump(data, f, indent=2)
    f.write("\n")
PY
            gum style --foreground 48 "✓ Tokyo Night Moon theme applied"
            log_success "Tokyo Night Moon theme applied"
        else
            log_warning "Failed to download Tokyo Night Moon theme"
        fi

        return 0
    else
        gum style --foreground 196 "✗ Failed to install OpenCode"
        log_error "Failed to install OpenCode"
        return 1
    fi
}
