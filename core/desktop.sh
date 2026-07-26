#!/bin/bash

# core/desktop.sh
# Desktop applications installation orchestrator

get_desktop_apps() {
    scan_installers "desktop"
}

install_desktop_apps() {
    log_info "Starting desktop applications installation..."

    gum style \
        --border rounded \
        --border-foreground 81 \
        --padding "1 2" \
        --bold \
        "Desktop Applications Installation"

    echo ""

    if ! check_installation_requirements; then
        gum style --foreground 196 "✗ Installation requirements check failed"
        log_error "Installation requirements check failed"
        gum confirm "Press Enter to continue..." && true
        return 1
    fi

    echo ""

    local available_apps=()
    while IFS= read -r app; do
        [ -z "$app" ] && continue
        available_apps+=("$app")
    done <<< "$(get_desktop_apps)"

    if [ ${#available_apps[@]} -eq 0 ]; then
        gum style --foreground 214 "⚠ No desktop applications found in desktop/ directory"
        log_warning "No desktop applications found"
        gum confirm "Press Enter to continue..." && true
        return 1
    fi

    gum style --foreground 81 --bold "Select applications to install (all selected by default):"
    echo ""

    local all_selected
    all_selected=$(IFS=,; echo "${available_apps[*]}")

    local selected_apps
    selected_apps=$(gum choose \
        --no-limit \
        --height 15 \
        --cursor.foreground 81 \
        --selected.foreground 48 \
        --header "Space=toggle | Enter=confirm | All selected by default" \
        --header.foreground 75 \
        --selected "$all_selected" \
        "${available_apps[@]}")

    if [ -z "$selected_apps" ]; then
        gum style --foreground 214 "No applications selected"
        log_info "User cancelled application selection"
        gum confirm "Press Enter to continue..." && true
        return 0
    fi

    echo ""
    gum style --foreground 81 "Installing selected applications..."
    echo ""

    log_info "Selected apps: $selected_apps"

    run_installers "$selected_apps" "desktop"

    show_install_summary "Installation Summary"

    echo ""
    gum confirm "Press Enter to continue..." && true

    return 0
}
