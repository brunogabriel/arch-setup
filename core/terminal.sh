#!/bin/bash

# core/terminal.sh
# Terminal tools installation orchestrator

# Get available terminal tools
get_terminal_tools() {
    local tools=()
    
    # Scan terminal/ directory for .sh files
    if [ -d "$INSTALL_DIR/terminal" ]; then
        for script in "$INSTALL_DIR/terminal"/*.sh; do
            if [ -f "$script" ]; then
                local tool_name=$(basename "$script" .sh)
                tools+=("$tool_name")
            fi
        done
    fi
    
    echo "${tools[@]}"
}

# Install terminal tools
install_terminal_tools() {
    log_info "Starting terminal tools installation..."
    
    gum style \
        --border rounded \
        --border-foreground 81 \
        --padding "1 2" \
        --bold \
        "Terminal Tools Installation"
    
    echo ""
    
    # Check installation requirements first
    if ! check_installation_requirements; then
        gum style --foreground 196 "✗ Installation requirements check failed"
        log_error "Installation requirements check failed"
        gum confirm "Press Enter to continue..." && true
        return 1
    fi
    
    echo ""
    
    # Get available tools
    local available_tools=($(get_terminal_tools))
    
    if [ ${#available_tools[@]} -eq 0 ]; then
        gum style --foreground 214 "⚠ No terminal tools found in terminal/ directory"
        log_warning "No terminal tools found"
        gum confirm "Press Enter to continue..." && true
        return 1
    fi
    
    # Show menu with available tools
    gum style --foreground 81 --bold "Select tools to install (all selected by default):"
    echo ""
    
    # Pre-select all tools by creating comma-separated list
    local all_selected=$(IFS=,; echo "${available_tools[*]}")
    
    local selected_tools=$(gum choose \
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
    
    # Debug: show selected tools
    log_info "Selected tools: $selected_tools"
    
    # Install each selected tool
    local success_count=0
    local fail_count=0
    
    while IFS= read -r tool; do
        # Skip empty lines
        [ -z "$tool" ] && continue
        
        local script="$INSTALL_DIR/terminal/${tool}.sh"
        
        if [ -f "$script" ]; then
            log_info "Installing $tool..."
            gum style --foreground 81 "→ Installing $tool..."
            
            # Convert tool name to function name (replace - with _)
            local func_name=$(echo "$tool" | tr '-' '_')
            
            # Source the script and call install function
            if source "$script" && install_${func_name}; then
                gum style --foreground 48 "✓ $tool installed successfully"
                log_success "$tool installed successfully"
                ((success_count++))
            else
                gum style --foreground 196 "✗ Failed to install $tool"
                log_error "Failed to install $tool"
                ((fail_count++))
            fi
            
            echo ""
        else
            gum style --foreground 196 "✗ Script not found: $script"
            log_error "Script not found: $script"
            ((fail_count++))
        fi
    done <<< "$selected_tools"
    
    # Summary
    gum style \
        --border rounded \
        --border-foreground 81 \
        --padding "1 2" \
        "Installation Summary" \
        "" \
        "$(gum style --foreground 48 "✓ Success: $success_count")" \
        "$(gum style --foreground 196 "✗ Failed: $fail_count")"
    
    log_info "Terminal tools installation completed: $success_count success, $fail_count failed"
    
    echo ""
    gum confirm "Press Enter to continue..." && true
    
    return 0
}
