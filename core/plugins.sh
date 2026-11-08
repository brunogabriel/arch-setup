#!/bin/bash

# core/plugins.sh
# Discover plugins grouped into plugins/<section>/<plugin-id>/.

is_kde_plasma() {
    local desktop="${XDG_CURRENT_DESKTOP:-} ${KDE_FULL_SESSION:-} ${KDE_SESSION_VERSION:-}"
    desktop=$(printf '%s' "$desktop" | tr '[:upper:]' '[:lower:]')
    [[ "$desktop" == *kde* || "$desktop" == *plasma* ]]
}

get_available_plugin_sections() {
    local section_dir
    local plugin_dir
    local section

    for section_dir in "$INSTALL_DIR"/plugins/*; do
        [ -d "$section_dir" ] || continue
        section=$(basename "$section_dir")
        if [ "$section" = "kde" ] && ! is_kde_plasma; then
            continue
        fi

        for plugin_dir in "$section_dir"/*; do
            [ -d "$plugin_dir" ] || continue
            [ -f "$plugin_dir/plugin.json" ] || continue
            [ -f "$plugin_dir/install.sh" ] || continue
            printf '%s\n' "$section"
            break
        done
    done | sort -u
}

get_available_plugins_in_section() {
    local section=$1
    local plugin_dir

    for plugin_dir in "$INSTALL_DIR/plugins/$section"/*; do
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
    local plugin_sections=()
    local plugin_choices=()
    local section_dir
    local section
    local plugin_dir
    local plugin_name
    local plugin_id
    local section_label

    while IFS= read -r section; do
        [ -n "$section" ] || continue
        section_dir="$INSTALL_DIR/plugins/$section"
        section_label=$(printf '%s' "$section" | tr '[:lower:]' '[:upper:]')

        while IFS= read -r plugin_dir; do
            [ -n "$plugin_dir" ] || continue
            plugin_name=$(get_plugin_name "$plugin_dir/plugin.json")
            plugin_id=$(basename "$plugin_dir")
            plugin_dirs+=("$plugin_dir")
            plugin_sections+=("$section")
            plugin_choices+=("[$section_label] $plugin_name [$plugin_id]")
        done <<< "$(get_available_plugins_in_section "$section")"
    done <<< "$(get_available_plugin_sections)"

    if [ "${#plugin_dirs[@]}" -eq 0 ]; then
        gum style --foreground "$UI_WARNING" "⚠ No plugins available for this desktop session"
        log_warning "No plugins available for this desktop session"
        gum confirm "Press Enter to continue..." && true
        return 0
    fi

    ui_header "Plugins" "[KDE] KDE Plasma integration"

    local selected
    selected=$(ui_multiselect "Choose plugins" false "${plugin_choices[@]}") || return 0

    if [ -z "$selected" ]; then
        gum style --foreground "$UI_WARNING" "No plugins selected"
        log_info "User selected no plugins"
        return 0
    fi

    local success_count=0
    local fail_count=0
    local selected_choice
    local index
    while IFS= read -r selected_choice; do
        [ -n "$selected_choice" ] || continue
        plugin_dir=""
        for index in "${!plugin_choices[@]}"; do
            if [ "${plugin_choices[$index]}" = "$selected_choice" ]; then
                plugin_dir=${plugin_dirs[$index]}
                break
            fi
        done

        if [ -z "$plugin_dir" ] || [ ! -f "$plugin_dir/install.sh" ]; then
            gum style --foreground "$UI_ERROR" "✗ Could not find the selected plugin installer"
            log_error "Could not resolve selected plugin: $selected_choice"
            ((fail_count++))
            continue
        fi

        if [ "${plugin_sections[$index]:-}" = "kde" ] && ! is_kde_plasma; then
            gum style --foreground "$UI_ERROR" "✗ KDE plugins can only be installed in a KDE Plasma session"
            log_warning "Blocked KDE plugin installation outside a KDE Plasma session"
            ((fail_count++))
            continue
        fi

        plugin_name=$(get_plugin_name "$plugin_dir/plugin.json")
        log_info "Installing plugin: $plugin_name"
        if bash "$plugin_dir/install.sh"; then
            gum style --foreground "$UI_SUCCESS" "✓ $plugin_name plugin installed successfully"
            log_success "$plugin_name plugin installed successfully"
            ((success_count++))
        else
            gum style --foreground "$UI_ERROR" "✗ Failed to install $plugin_name plugin"
            log_error "Failed to install $plugin_name plugin"
            ((fail_count++))
        fi
    done <<< "$selected"

    gum style \
        --border rounded \
        --border-foreground "$UI_ACCENT" \
        --padding "1 2" \
        "Plugin Installation Complete" \
        "" \
        "$(gum style --foreground "$UI_SUCCESS" "✓ Installed: $success_count")" \
        "$(gum style --foreground "$UI_ERROR" "✗ Failed: $fail_count")"

    log_info "Plugin installation completed: $success_count success, $fail_count failed"
    gum confirm "Press Enter to continue..." && true
    [ "$fail_count" -eq 0 ]
}
