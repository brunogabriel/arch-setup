#!/bin/bash

# core/desktop.sh
# Desktop applications installation orchestrator

get_desktop_apps() {
    scan_installers "desktop"
}

install_desktop_apps() {
    log_info "Starting desktop applications installation..."

    ui_header "Desktop Applications" "Select the applications you want to install."

    echo ""

    if ! check_installation_requirements; then
        gum style --foreground "$UI_ERROR" "✗ Installation requirements check failed"
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
        gum style --foreground "$UI_WARNING" "⚠ No desktop applications found in desktop/ directory"
        log_warning "No desktop applications found"
        gum confirm "Press Enter to continue..." && true
        return 1
    fi

    local selected_apps
    selected_apps=$(ui_multiselect "All applications selected by default" true "${available_apps[@]}") || return 0

    if [ -z "$selected_apps" ]; then
        gum style --foreground "$UI_WARNING" "No applications selected"
        log_info "User cancelled application selection"
        gum confirm "Press Enter to continue..." && true
        return 0
    fi

    echo ""
    gum style --foreground "$UI_ACCENT" "Installing selected applications..."
    echo ""

    log_info "Selected apps: $selected_apps"

    run_installers "$selected_apps" "desktop"

    show_install_summary "Installation Summary"

    echo ""
    gum confirm "Press Enter to continue..." && true

    return 0
}
