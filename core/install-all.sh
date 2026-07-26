#!/bin/bash

# core/install-all.sh
# Install All - Terminal Tools + Desktop Applications

install_all() {
    log_info "Starting full installation (Terminal + Desktop)..."

    gum style \
        --border double \
        --border-foreground 81 \
        --padding "1 2" \
        --bold \
        "Install All" \
        "" \
        "$(gum style --foreground 75 "This will install ALL terminal tools and desktop applications")" \
        "$(gum style --foreground 75 "No user interaction required - just sit back and relax!")"

    echo ""

    if ! check_installation_requirements; then
        gum style --foreground 196 "✗ Installation requirements check failed"
        log_error "Installation requirements check failed"
        gum confirm "Press Enter to continue..." && true
        return 1
    fi

    echo ""

    local terminal_tools desktop_apps total_items
    terminal_tools=$(get_terminal_tools)
    desktop_apps=$(get_desktop_apps)
    total_items=$(( $(echo "$terminal_tools" | grep -c .) + $(echo "$desktop_apps" | grep -c .) ))

    gum style --foreground 81 --bold "Found $total_items items to install:"
    gum style --foreground 75 "  • $(echo "$terminal_tools" | grep -c .) terminal tools"
    gum style --foreground 75 "  • $(echo "$desktop_apps" | grep -c .) desktop applications"
    echo ""

    # Install terminal tools
    gum style \
        --border rounded \
        --border-foreground 81 \
        --padding "1 2" \
        "Installing Terminal Tools ($(echo "$terminal_tools" | grep -c .) items)"
    echo ""

    run_installers "$terminal_tools" "terminal" true

    local terminal_success=$SUCCESS_COUNT terminal_fail=$FAIL_COUNT

    # Install desktop applications
    gum style \
        --border rounded \
        --border-foreground 81 \
        --padding "1 2" \
        "Installing Desktop Applications ($(echo "$desktop_apps" | grep -c .) items)"
    echo ""

    run_installers "$desktop_apps" "desktop" true

    SUCCESS_COUNT=$((terminal_success + SUCCESS_COUNT))
    FAIL_COUNT=$((terminal_fail + FAIL_COUNT))

    # Final summary
    echo ""
    gum style \
        --border double \
        --border-foreground 81 \
        --padding "1 2" \
        --bold \
        "Installation Complete!" \
        "" \
        "$(gum style --foreground 48 "✓ Successfully installed: $SUCCESS_COUNT")" \
        "$(gum style --foreground 196 "✗ Failed: $FAIL_COUNT")" \
        "" \
        "$(gum style --foreground 75 "Total items: $total_items")"

    log_info "Install All completed: $SUCCESS_COUNT success, $FAIL_COUNT failed"

    echo ""
    gum confirm "Press Enter to continue..." && true

    return 0
}
