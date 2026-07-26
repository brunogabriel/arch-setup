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

    gum style \
        --border rounded \
        --border-foreground 81 \
        --padding "1 2" \
        --bold \
        "Terminal Tools Installation"

    echo ""

    if ! check_installation_requirements; then
        gum style --foreground 196 "✗ Installation requirements check failed"
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
        gum style --foreground 214 "⚠ No terminal tools found in terminal/ directory"
        log_warning "No terminal tools found"
        gum confirm "Press Enter to continue..." && true
        return 1
    fi

    gum style --foreground 81 --bold "Select tools to install (all selected by default):"
    echo ""

    local all_selected
    all_selected=$(IFS=,; echo "${available_tools[*]}")

    local selected_tools
    selected_tools=$(gum choose \
        --no-limit \
        --height 15 \
        --cursor.foreground 81 \
        --selected.foreground 48 \
        --header "Space=toggle | Enter=confirm | All selected by default" \
        --header.foreground 75 \
        --selected "$all_selected" \
        "${available_tools[@]}")

    if [ -z "$selected_tools" ]; then
        gum style --foreground 214 "No tools selected"
        log_info "User cancelled tool selection"
        gum confirm "Press Enter to continue..." && true
        return 0
    fi

    echo ""
    gum style --foreground 81 "Installing selected tools..."
    echo ""

    log_info "Selected tools: $selected_tools"

    run_installers "$selected_tools" "terminal"

    show_install_summary "Installation Summary"

    echo ""
    gum confirm "Press Enter to continue..." && true

    return 0
}
