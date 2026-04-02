#!/bin/bash

# core/extras.sh
# System / Hardware extras installation orchestrator

# Get available extras
get_extras() {
    local items=()

    # Scan extras/ directory for .sh files
    if [ -d "$INSTALL_DIR/extras" ]; then
        for script in "$INSTALL_DIR/extras"/*.sh; do
            if [ -f "$script" ]; then
                local item_name=$(basename "$script" .sh)
                items+=("$item_name")
            fi
        done
    fi

    echo "${items[@]}"
}

# Install system / hardware extras
install_extras() {
    log_info "Starting system/hardware extras installation..."

    gum style \
        --border rounded \
        --border-foreground 81 \
        --padding "1 2" \
        --bold \
        "System / Hardware Extras"

    echo ""

    # Get available extras
    local available_items=($(get_extras))

    if [ ${#available_items[@]} -eq 0 ]; then
        gum style --foreground 214 "⚠ No extras found in extras/ directory"
        log_warning "No extras found"
        gum confirm "Press Enter to continue..." && true
        return 1
    fi

    # Show menu with available extras
    gum style --foreground 81 --bold "Select extras to install (all selected by default):"
    echo ""

    # Pre-select all items by creating comma-separated list
    local all_selected=$(IFS=,; echo "${available_items[*]}")

    local selected_items=$(gum choose \
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

    # Install each selected extra
    local success_count=0
    local fail_count=0

    while IFS= read -r item; do
        # Skip empty lines
        [ -z "$item" ] && continue

        local script="$INSTALL_DIR/extras/${item}.sh"

        if [ -f "$script" ]; then
            log_info "Installing $item..."
            gum style --foreground 81 "→ Installing $item..."

            # Convert item name to function name (replace - with _)
            local func_name=$(echo "$item" | tr '-' '_')

            # Source the script and call install function
            if source "$script" && install_${func_name}; then
                gum style --foreground 48 "✓ $item installed successfully"
                log_success "$item installed successfully"
                ((success_count++))
            else
                gum style --foreground 196 "✗ Failed to install $item"
                log_error "Failed to install $item"
                ((fail_count++))
            fi

            echo ""
        else
            gum style --foreground 196 "✗ Script not found: $script"
            log_error "Script not found: $script"
            ((fail_count++))
        fi
    done <<< "$selected_items"

    # Summary
    gum style \
        --border rounded \
        --border-foreground 81 \
        --padding "1 2" \
        "Installation Summary" \
        "" \
        "$(gum style --foreground 48 "✓ Success: $success_count")" \
        "$(gum style --foreground 196 "✗ Failed: $fail_count")"

    log_info "Extras installation completed: $success_count success, $fail_count failed"

    echo ""
    gum confirm "Press Enter to continue..." && true

    return 0
}
