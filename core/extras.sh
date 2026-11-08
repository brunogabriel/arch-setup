#!/bin/bash

# core/extras.sh
# System / Hardware extras installation orchestrator

get_extras() {
    scan_installers "extras"
}

install_extras() {
    log_info "Starting system/hardware extras installation..."

    ui_header "System / Hardware Extras" "Select the extras you want to install."

    echo ""

    if ! check_installation_requirements; then
        gum style --foreground "$UI_ERROR" "✗ Installation requirements check failed"
        log_error "Installation requirements check failed"
        gum confirm "Press Enter to continue..." && true
        return 1
    fi

    echo ""

    local available_items=()
    while IFS= read -r item; do
        [ -z "$item" ] && continue
        available_items+=("$item")
    done <<< "$(get_extras)"

    if [ ${#available_items[@]} -eq 0 ]; then
        gum style --foreground "$UI_WARNING" "⚠ No extras found in extras/ directory"
        log_warning "No extras found"
        gum confirm "Press Enter to continue..." && true
        return 1
    fi

    local selected_items
    selected_items=$(ui_multiselect "All extras selected by default" true "${available_items[@]}") || return 0

    if [ -z "$selected_items" ]; then
        gum style --foreground "$UI_WARNING" "No extras selected"
        log_info "User cancelled extras selection"
        gum confirm "Press Enter to continue..." && true
        return 0
    fi

    echo ""
    gum style --foreground "$UI_ACCENT" "Installing selected extras..."
    echo ""

    log_info "Selected extras: $selected_items"

    run_installers "$selected_items" "extras"

    show_install_summary "Installation Summary"

    echo ""
    gum confirm "Press Enter to continue..." && true

    return 0
}
