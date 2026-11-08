#!/usr/bin/env bash
# Install or update the AI Usage Plasma 6 widget for the current user.

plugin_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
package_dir="$plugin_dir/package"
plasmoid_id="io.github.archsetup.ai-usage"
destination="${XDG_DATA_HOME:-$HOME/.local/share}/plasma/plasmoids/$plasmoid_id"
icon_destination="${XDG_DATA_HOME:-$HOME/.local/share}/icons/hicolor/scalable/apps/arch-setup-codex-symbolic.svg"
widget_icon_destination="${XDG_DATA_HOME:-$HOME/.local/share}/icons/hicolor/scalable/apps/arch-setup-ai-providers-usage-symbolic.svg"
openrouter_icon_destination="${XDG_DATA_HOME:-$HOME/.local/share}/icons/hicolor/scalable/apps/arch-setup-openrouter-symbolic.svg"

if ! command -v gum >/dev/null 2>&1; then
    exit 1
fi

if [ ! -f "$package_dir/metadata.json" ] || [ ! -f "$package_dir/contents/ui/main.qml" ]; then
    gum style --foreground 196 "✗ Plasma widget package is incomplete"
    exit 1
fi

gum style --foreground 81 "→ Installing AI Usage for Plasma..."

if ! command -v kpackagetool6 >/dev/null 2>&1; then
    gum style --foreground 196 "✗ kpackagetool6 is required to install Plasma widgets"
    exit 1
fi

if kpackagetool6 --type Plasma/Applet --list | grep -Fqx "$plasmoid_id"; then
    package_action="--upgrade"
else
    package_action="--install"
fi

if ! kpackagetool6 --type Plasma/Applet "$package_action" "$package_dir"; then
    gum style --foreground 196 "✗ kpackagetool6 failed to install the Plasma widget"
    exit 1
fi

if ! install -D -m 644 "$package_dir/contents/images/codex.svg" "$icon_destination"; then
    gum style --foreground 196 "✗ Failed to install the Codex tray icon"
    exit 1
fi

if ! install -D -m 644 "$package_dir/contents/images/ai-providers-usage-symbolic.svg" "$widget_icon_destination"; then
    gum style --foreground 196 "✗ Failed to install the AI Usage widget icon"
    exit 1
fi

if ! install -D -m 644 "$package_dir/contents/images/openrouter.svg" "$openrouter_icon_destination"; then
    gum style --foreground 196 "✗ Failed to install the OpenRouter icon"
    exit 1
fi

if command -v kbuildsycoca6 >/dev/null 2>&1; then
    kbuildsycoca6 --noincremental >/dev/null 2>&1 || true
fi

gum style --foreground 48 "✓ AI Usage for Plasma installed or updated at $destination"
gum style --foreground 214 "If an old widget instance is already loaded, log out and back in to reload it."
gum style --foreground 214 "Enable ‘AI Usage’ in System Tray settings; do not add a separate panel widget."
gum style --foreground 214 "The Codex provider requires the Codex CLI to be installed and logged in."
exit 0
