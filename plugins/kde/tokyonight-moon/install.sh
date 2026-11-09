#!/usr/bin/env bash
# Install the Tokyo Night Moon color scheme for the current user.

plugin_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
scheme_file="$plugin_dir/scheme/TokyoNightMoon.colors"
destination="${XDG_DATA_HOME:-$HOME/.local/share}/color-schemes/TokyoNightMoon.colors"

if ! command -v gum >/dev/null 2>&1; then
    exit 1
fi

if [ ! -f "$scheme_file" ]; then
    gum style --foreground 196 "✗ TokyoNightMoon.colors is missing from the plugin payload"
    exit 1
fi

gum style --foreground 81 "→ Installing Tokyo Night Moon color scheme..."

if ! install -D -m 644 "$scheme_file" "$destination"; then
    gum style --foreground 196 "✗ Failed to write the color scheme to $destination"
    exit 1
fi

if command -v kbuildsycoca6 >/dev/null 2>&1; then
    kbuildsycoca6 --noincremental >/dev/null 2>&1 || true
fi

gum style --foreground 48 "✓ Tokyo Night Moon color scheme installed at $destination"
gum style --foreground 214 "Apply it in System Settings → Colors (search for 'Tokyo Night Moon')."
gum style --foreground 214 "Pill/App-style window decorations (Aurorae/Klassy themes) are separate from this color scheme."
exit 0
