#!/bin/bash

# core/plugins.sh
# Discover and install app-specific integrations from plugins/<plugin>/.

get_available_plugins() {
    local plugin_dir

    for plugin_dir in "$INSTALL_DIR"/plugins/*; do
        [ -d "$plugin_dir" ] || continue
        [ -f "$plugin_dir/plugin.json" ] || continue
        [ -f "$plugin_dir/install.sh" ] || continue
        printf '%s\n' "$plugin_dir"
    done
}

get_plugin_name() {
    local manifest=$1
    local name=""

    if command -v python3 >/dev/null 2>&1; then
        name=$(python3 -c 'import json, sys; print(json.load(open(sys.argv[1])).get("name", ""))' "$manifest" 2>/dev/null)
    fi

    if [ -z "$name" ]; then
        name="$(basename "$(dirname "$manifest")")"
    fi

    printf '%s' "$name"
}

install_plugins() {
    log_info "Opening plugin installer..."

    local plugin_dirs=()
    local plugin_choices=()
    local plugin_dir
    local plugin_name

    while IFS= read -r plugin_dir; do
        [ -n "$plugin_dir" ] || continue
        plugin_name=$(get_plugin_name "$plugin_dir/plugin.json")
        plugin_dirs+=("$plugin_dir")
        plugin_choices+=("$plugin_name")
    done <<< "$(get_available_plugins)"

    if [ "${#plugin_dirs[@]}" -eq 0 ]; then
        gum style --foreground 214 "⚠ No plugins found in plugins/"
        log_warning "No plugins found"
        gum confirm "Press Enter to continue..." && true
        return 0
    fi

    local selected
    selected=$(gum choose \
        --cursor.foreground 81 \
        --header "Choose a plugin to install or update:" \
        --header.foreground 81 \
        "${plugin_choices[@]}") || return 0

    local index
    for index in "${!plugin_choices[@]}"; do
        if [ "${plugin_choices[$index]}" = "$selected" ]; then
            plugin_dir=${plugin_dirs[$index]}
            break
        fi
    done

    if [ -z "$plugin_dir" ] || [ ! -f "$plugin_dir/install.sh" ]; then
        gum style --foreground 196 "✗ Could not find the selected plugin installer"
        log_error "Could not resolve selected plugin: $selected"
        return 1
    fi

    plugin_name=$(get_plugin_name "$plugin_dir/plugin.json")
    log_info "Installing plugin: $plugin_name"
    if bash "$plugin_dir/install.sh"; then
        gum style --foreground 48 "✓ $plugin_name plugin installed successfully"
        log_success "$plugin_name plugin installed successfully"
        return 0
    fi

    gum style --foreground 196 "✗ Failed to install $plugin_name plugin"
    log_error "Failed to install $plugin_name plugin"
    return 1
}
