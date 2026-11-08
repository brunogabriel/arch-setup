#!/bin/bash

# core/terminal.sh
# Terminal tools installation orchestrator

get_terminal_tools() {
    local items
    items=$(scan_installers "terminal")

    # Reorder: put zsh first if present (makes it default terminal early)
    local result=()
    local has_zsh=false
    while IFS= read -r item; do
        [ -z "$item" ] && continue
        if [ "$item" = "zsh" ]; then
            has_zsh=true
        else
            result+=("$item")
        fi
    done <<< "$items"

    if $has_zsh; then
        result=("zsh" "${result[@]}")
    fi

    printf '%s\n' "${result[@]}"
}

install_terminal_tools() {
    log_info "Starting terminal tools installation..."

    ui_header "Terminal Tools" "Select the tools you want to install."

    echo ""

    if ! check_installation_requirements; then
        gum style --foreground "$UI_ERROR" "✗ Installation requirements check failed"
        log_error "Installation requirements check failed"
        gum confirm "Press Enter to continue..." && true
        return 1
    fi

    echo ""

    local available_tools=()
    while IFS= read -r tool; do
        [ -z "$tool" ] && continue
        available_tools+=("$tool")
    done <<< "$(get_terminal_tools)"

    if [ ${#available_tools[@]} -eq 0 ]; then
        gum style --foreground "$UI_WARNING" "⚠ No terminal tools found in terminal/ directory"
        log_warning "No terminal tools found"
        gum confirm "Press Enter to continue..." && true
        return 1
    fi

    local selected_tools
    selected_tools=$(ui_multiselect "All tools selected by default" true "${available_tools[@]}") || return 0

    if [ -z "$selected_tools" ]; then
        gum style --foreground "$UI_WARNING" "No tools selected"
        log_info "User cancelled tool selection"
        gum confirm "Press Enter to continue..." && true
        return 0
    fi

    echo ""
    gum style --foreground "$UI_ACCENT" "Installing selected tools..."
    echo ""

    log_info "Selected tools: $selected_tools"

    run_installers "$selected_tools" "terminal"

    show_install_summary "Installation Summary"

    echo ""
    gum confirm "Press Enter to continue..." && true

    return 0
}
