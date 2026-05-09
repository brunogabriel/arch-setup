#!/bin/bash

# menu_actions/custom-install.sh
# Custom Install - select individual tools from terminal and/or desktop

custom_install() {
    log_info "Starting custom install..."

    gum style \
        --border rounded \
        --border-foreground 81 \
        --padding "1 2" \
        --bold \
        "Custom Install" \
        "" \
        "$(gum style --foreground 75 "Pick individual tools and applications to install")"

    echo ""

    if ! check_installation_requirements; then
        gum style --foreground 196 "✗ Installation requirements check failed"
        log_error "Installation requirements check failed"
        gum confirm "Press Enter to continue..." && true
        return 1
    fi

    echo ""

    # Build combined list with category prefix
    local items=()
    local terminal_tools=($(get_terminal_tools))
    for tool in "${terminal_tools[@]}"; do
        items+=("[T] $tool")
    done

    # Include desktop apps only when a display server is available
    if [ -n "$DISPLAY" ] || [ -n "$WAYLAND_DISPLAY" ]; then
        local desktop_apps=($(get_desktop_apps))
        for app in "${desktop_apps[@]}"; do
            items+=("[D] $app")
        done
    fi

    if [ ${#items[@]} -eq 0 ]; then
        gum style --foreground 214 "⚠ No tools found"
        gum confirm "Press Enter to continue..." && true
        return 1
    fi

    gum style --foreground 81 --bold "Select tools to install:"
    gum style --foreground 75 "[T] = Terminal tool  |  [D] = Desktop application"
    echo ""

    local selected
    selected=$(gum choose \
        --no-limit \
        --height 20 \
        --cursor.foreground 81 \
        --selected.foreground 48 \
        --header "Space=toggle | Enter=confirm" \
        --header.foreground 75 \
        "${items[@]}")

    if [ -z "$selected" ]; then
        gum style --foreground 214 "No tools selected"
        log_info "User cancelled custom install"
        gum confirm "Press Enter to continue..." && true
        return 0
    fi

    echo ""

    local success_count=0
    local fail_count=0
    local total
    total=$(echo "$selected" | wc -l)
    local current=0

    while IFS= read -r item; do
        ((current++))
        local category="${item:1:1}"  # T or D
        local name="${item:4}"        # strip "[T] " or "[D] "
        local func_name
        func_name=$(echo "$name" | tr '-' '_')
        local script=""

        if [ "$category" = "T" ]; then
            script="$INSTALL_DIR/terminal/${name}.sh"
        else
            script="$INSTALL_DIR/desktop/${name}.sh"
        fi

        log_info "[$current/$total] Installing $name..."
        gum style --foreground 81 "[$current/$total] → Installing $name..."

        if [ -f "$script" ]; then
            if source "$script" && install_${func_name}; then
                gum style --foreground 48 "  ✓ $name installed successfully"
                log_success "$name installed successfully"
                ((success_count++))
            else
                gum style --foreground 196 "  ✗ Failed to install $name"
                log_error "Failed to install $name"
                ((fail_count++))
            fi
        else
            gum style --foreground 196 "  ✗ Script not found: $script"
            log_error "Script not found: $script"
            ((fail_count++))
        fi
        echo ""
    done <<< "$selected"

    gum style \
        --border rounded \
        --border-foreground 81 \
        --padding "1 2" \
        "Custom Install Complete" \
        "" \
        "$(gum style --foreground 48 "✓ Installed: $success_count")" \
        "$(gum style --foreground 196 "✗ Failed: $fail_count")"

    log_info "Custom install completed: $success_count success, $fail_count failed"

    echo ""
    gum confirm "Press Enter to continue..." && true
    return 0
}
