#!/bin/bash

# core/desktop.sh
# Desktop applications installation orchestrator

# Get available desktop applications
get_desktop_apps() {
    local apps=()
    
    # Scan desktop/ directory for .sh files
    if [ -d "$INSTALL_DIR/desktop" ]; then
        for script in "$INSTALL_DIR/desktop"/*.sh; do
            if [ -f "$script" ]; then
                local app_name=$(basename "$script" .sh)
                apps+=("$app_name")
            fi
        done
    fi
    
    echo "${apps[@]}"
}

# Install desktop applications
install_desktop_apps() {
    log_info "Starting desktop applications installation..."
    
    gum style \
        --border rounded \
        --border-foreground 81 \
        --padding "1 2" \
        --bold \
        "Desktop Applications Installation"
    
    echo ""
    
    # Check installation requirements first
    if ! check_installation_requirements; then
        gum style --foreground 196 "✗ Installation requirements check failed"
        log_error "Installation requirements check failed"
        gum confirm "Press Enter to continue..." && true
        return 1
    fi
    
    echo ""
    
    # Get available apps
    local available_apps=($(get_desktop_apps))
    
    if [ ${#available_apps[@]} -eq 0 ]; then
        gum style --foreground 214 "⚠ No desktop applications found in desktop/ directory"
        log_warning "No desktop applications found"
        gum confirm "Press Enter to continue..." && true
        return 1
    fi
    
    # Show menu with available apps
    gum style --foreground 81 --bold "Select applications to install (all selected by default):"
    echo ""
    
    # Pre-select all apps by creating comma-separated list
    local all_selected=$(IFS=,; echo "${available_apps[*]}")
    
    local selected_apps=$(gum choose \
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
    
    # Debug: show selected apps
    log_info "Selected apps: $selected_apps"
    
    # Install each selected app
    local success_count=0
    local fail_count=0
    
    while IFS= read -r app; do
        # Skip empty lines
        [ -z "$app" ] && continue
        
        local script="$INSTALL_DIR/desktop/${app}.sh"
        
        if [ -f "$script" ]; then
            log_info "Installing $app..."
            gum style --foreground 81 "→ Installing $app..."
            
            # Convert app name to function name (replace - with _)
            local func_name=$(echo "$app" | tr '-' '_')
            
            # Source the script and call install function
            if source "$script" && install_${func_name}; then
                gum style --foreground 48 "✓ $app installed successfully"
                log_success "$app installed successfully"
                ((success_count++))
            else
                gum style --foreground 196 "✗ Failed to install $app"
                log_error "Failed to install $app"
                ((fail_count++))
            fi
            
            echo ""
        else
            gum style --foreground 196 "✗ Script not found: $script"
            log_error "Script not found: $script"
            ((fail_count++))
        fi
    done <<< "$selected_apps"
    
    # Summary
    gum style \
        --border rounded \
        --border-foreground 81 \
        --padding "1 2" \
        "Installation Summary" \
        "" \
        "$(gum style --foreground 48 "✓ Success: $success_count")" \
        "$(gum style --foreground 196 "✗ Failed: $fail_count")"
    
    log_info "Desktop applications installation completed: $success_count success, $fail_count failed"
    
    echo ""
    gum confirm "Press Enter to continue..." && true
    
    return 0
}
