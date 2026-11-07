#!/usr/bin/env bash
# Install or update the Arch Setup integration for Herdr App.

install_herdr_app_plugin() {
    local plugin_dir
    plugin_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    local herdr_config_dir="${HERDR_APP_HOME:-${XDG_CONFIG_HOME:-$HOME/.config}/herdr-app}"
    local relative_path
    local mode
    local source
    local destination
    local files=(
        "layouts/codex-usage.json"
        "mods/codex-usage/main.js"
        "mods/codex-usage/mod.json"
        "mods/codex-usage/read_usage.py"
        "mods/workspace-chrome-personal/main.js"
        "mods/workspace-chrome-personal/mod.json"
        "mods/workspace-chrome-personal/plus.svg"
        "mods/workspace-chrome-personal/search.svg"
        "mods/workspace-chrome-personal/settings.svg"
        "mods/workspace-chrome-personal/sidebar.svg"
    )

    if ! command -v gum >/dev/null 2>&1; then
        return 1
    fi

    gum style --foreground 81 "→ Installing Arch Setup's Herdr App plugin..."

    for relative_path in "${files[@]}"; do
        source="$plugin_dir/$relative_path"
        destination="$herdr_config_dir/$relative_path"
        mode=644
        if [[ "$relative_path" == "mods/codex-usage/read_usage.py" ]]; then
            mode=755
        fi

        if ! install -D -m "$mode" "$source" "$destination"; then
            gum style --foreground 196 "✗ Failed to install $relative_path"
            return 1
        fi
    done

    gum style --foreground 48 "✓ Arch Setup's Herdr App plugin installed"

    # Switch only an already-running Herdr window; never launch the app here.
    if command -v herdr-app >/dev/null 2>&1 && herdr-app status >/dev/null 2>&1; then
        if herdr-app do layout.switch '{"name":"codex-usage"}' >/dev/null 2>&1; then
            gum style --foreground 48 "✓ Herdr App switched to the codex-usage layout"
        else
            gum style --foreground 214 "! Select the codex-usage layout in Herdr App Settings"
        fi
    else
        gum style --foreground 214 "! Open Herdr App and select the codex-usage layout in Settings"
    fi

    return 0
}

install_herdr_app_plugin "$@"
