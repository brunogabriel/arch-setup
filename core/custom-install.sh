#!/bin/bash

# core/custom-install.sh
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
    while IFS= read -r tool; do
        [ -z "$tool" ] && continue
        items+=("[T] $tool")
    done <<< "$(get_terminal_tools)"

    # Include desktop apps only when a display server is available
    if [ -n "$DISPLAY" ] || [ -n "$WAYLAND_DISPLAY" ]; then
        while IFS= read -r app; do
            [ -z "$app" ] && continue
            items+=("[D] $app")
        done <<< "$(get_desktop_apps)"
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

    local total
    total=$(echo "$selected" | grep -c .)

    run_installers "$selected" "" true

    gum style \
        --border rounded \
        --border-foreground 81 \
        --padding "1 2" \
        "Custom Install Complete" \
        "" \
        "$(gum style --foreground 48 "✓ Installed: $SUCCESS_COUNT")" \
        "$(gum style --foreground 196 "✗ Failed: $FAIL_COUNT")"

    log_info "Custom install completed: $SUCCESS_COUNT success, $FAIL_COUNT failed"

    echo ""
    gum confirm "Press Enter to continue..." && true
    return 0
}
