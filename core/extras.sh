#!/bin/bash

# core/extras.sh
# System / Hardware extras installation orchestrator

get_extras() {
    scan_installers "extras"
}

install_extras() {
    log_info "Starting system/hardware extras installation..."

    gum style \
        --border rounded \
        --border-foreground 81 \
        --padding "1 2" \
        --bold \
        "System / Hardware Extras"

    echo ""

    if ! check_installation_requirements; then
        gum style --foreground 196 "✗ Installation requirements check failed"
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
        gum style --foreground 214 "⚠ No extras found in extras/ directory"
        log_warning "No extras found"
        gum confirm "Press Enter to continue..." && true
        return 1
    fi

    gum style --foreground 81 --bold "Select extras to install (all selected by default):"
    echo ""

    local all_selected
    all_selected=$(IFS=,; echo "${available_items[*]}")

    local selected_items
    selected_items=$(gum choose \
        --no-limit \
        --height 15 \
        --cursor.foreground 81 \
        --selected.foreground 48 \
        --header "Space=toggle | Enter=confirm | All selected by default" \
        --header.foreground 75 \
        --selected "$all_selected" \
        "${available_items[@]}")

    if [ -z "$selected_items" ]; then
        gum style --foreground 214 "No extras selected"
        log_info "User cancelled extras selection"
        gum confirm "Press Enter to continue..." && true
        return 0
    fi

    echo ""
    gum style --foreground 81 "Installing selected extras..."
    echo ""

    log_info "Selected extras: $selected_items"

    run_installers "$selected_items" "extras"

    show_install_summary "Installation Summary"

    echo ""
    gum confirm "Press Enter to continue..." && true

    return 0
}
