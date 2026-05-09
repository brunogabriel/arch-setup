#!/bin/bash

# menu_actions/install-all.sh
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
    
    # Check installation requirements first
    if ! check_installation_requirements; then
        gum style --foreground 196 "✗ Installation requirements check failed"
        log_error "Installation requirements check failed"
        gum confirm "Press Enter to continue..." && true
        return 1
    fi
    
    echo ""
    
    # Get all available tools and apps
    local terminal_tools=($(get_terminal_tools))
    local desktop_apps=($(get_desktop_apps))
    local total_items=$((${#terminal_tools[@]} + ${#desktop_apps[@]}))
    
    gum style --foreground 81 --bold "Found $total_items items to install:"
    gum style --foreground 75 "  • ${#terminal_tools[@]} terminal tools"
    gum style --foreground 75 "  • ${#desktop_apps[@]} desktop applications"
    echo ""
    
    # Counters
    local success_count=0
    local fail_count=0
    local current=0
    
    # Install all terminal tools
    gum style \
        --border rounded \
        --border-foreground 81 \
        --padding "1 2" \
        "Installing Terminal Tools (${#terminal_tools[@]} items)"
    echo ""
    
    for tool in "${terminal_tools[@]}"; do
        ((current++))
        local script="$INSTALL_DIR/terminal/${tool}.sh"
        
        if [ -f "$script" ]; then
            log_info "[$current/$total_items] Installing $tool..."
            gum style --foreground 81 "[$current/$total_items] → Installing $tool..."
            
            # Convert tool name to function name (replace - with _)
            local func_name=$(echo "$tool" | tr '-' '_')
            
            # Source the script and call install function
            if source "$script" && install_${func_name}; then
                gum style --foreground 48 "  ✓ $tool installed successfully"
                log_success "$tool installed successfully"
                ((success_count++))
            else
                gum style --foreground 196 "  ✗ Failed to install $tool"
                log_error "Failed to install $tool"
                ((fail_count++))
            fi
            echo ""
        else
            gum style --foreground 196 "  ✗ Script not found: $script"
            log_error "Script not found: $script"
            ((fail_count++))
        fi
    done
    
    # Install all desktop applications
    gum style \
        --border rounded \
        --border-foreground 81 \
        --padding "1 2" \
        "Installing Desktop Applications (${#desktop_apps[@]} items)"
    echo ""
    
    for app in "${desktop_apps[@]}"; do
        ((current++))
        local script="$INSTALL_DIR/desktop/${app}.sh"
        
        if [ -f "$script" ]; then
            log_info "[$current/$total_items] Installing $app..."
            gum style --foreground 81 "[$current/$total_items] → Installing $app..."
            
            # Convert app name to function name (replace - with _)
            local func_name=$(echo "$app" | tr '-' '_')
            
            # Source the script and call install function
            if source "$script" && install_${func_name}; then
                gum style --foreground 48 "  ✓ $app installed successfully"
                log_success "$app installed successfully"
                ((success_count++))
            else
                gum style --foreground 196 "  ✗ Failed to install $app"
                log_error "Failed to install $app"
                ((fail_count++))
            fi
            echo ""
        else
            gum style --foreground 196 "  ✗ Script not found: $script"
            log_error "Script not found: $script"
            ((fail_count++))
        fi
    done
    
    # Final Summary
    echo ""
    gum style \
        --border double \
        --border-foreground 81 \
        --padding "1 2" \
        --bold \
        "Installation Complete!" \
        "" \
        "$(gum style --foreground 48 "✓ Successfully installed: $success_count")" \
        "$(gum style --foreground 196 "✗ Failed: $fail_count")" \
        "" \
        "$(gum style --foreground 75 "Total items: $total_items")"
    
    log_info "Install All completed: $success_count success, $fail_count failed"
    
    echo ""
    gum confirm "Press Enter to continue..." && true
    
    return 0
}
