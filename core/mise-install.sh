#!/bin/bash

# core/mise-install.sh
# Programming languages installation orchestrator via mise

# Get list of available languages in mise_installs directory
get_mise_languages() {
    local languages=()
    
    # Find all .sh files in mise_installs directory
    if [ -d "$INSTALL_DIR/mise_installs" ]; then
        for file in "$INSTALL_DIR/mise_installs"/*.sh; do
            if [ -f "$file" ]; then
                # Extract filename without extension
                local lang=$(basename "$file" .sh)
                languages+=("$lang")
            fi
        done
    fi
    
    echo "${languages[@]}"
}

# Install programming language via mise
install_programming_language() {
    log_info "Starting programming language installation menu..."
    
    clear
    gum style \
        --border double \
        --border-foreground 81 \
        --padding "1 2" \
        --bold \
        "Install Programming Languages" \
        "" \
        "$(gum style --foreground 75 "Manage language versions via mise")"
    
    echo ""
    
    # Check if mise is installed
    if ! command -v mise &> /dev/null; then
        gum style --foreground 196 "✗ mise is not installed!"
        gum style --foreground 214 "→ Please install Terminal Tools first (Option 3)"
        log_error "mise not installed - cannot install programming languages"
        echo ""
        gum confirm "Press Enter to continue..." && true
        return 1
    fi
    
    # Get available languages
    local languages=($(get_mise_languages))
    
    if [ ${#languages[@]} -eq 0 ]; then
        gum style --foreground 196 "✗ No languages available"
        log_error "No language installers found in mise_installs/"
        echo ""
        gum confirm "Press Enter to continue..." && true
        return 1
    fi
    
    # Show menu to select language
    gum style \
        --border rounded \
        --border-foreground 81 \
        --padding "1 2" \
        "Available Languages (${#languages[@]} total)"
    
    echo ""
    
    local choice=$(gum choose \
        --cursor.foreground 81 \
        --header "Select language to install:" \
        --header.foreground 81 \
        "${languages[@]}")
    
    if [ -z "$choice" ]; then
        gum style --foreground 214 "No language selected"
        echo ""
        gum confirm "Press Enter to continue..." && true
        return 0
    fi
    
    echo ""
    log_info "Selected language: $choice"
    
    # Source and execute the installer
    local script="$INSTALL_DIR/mise_installs/${choice}.sh"
    
    if [ ! -f "$script" ]; then
        gum style --foreground 196 "✗ Installer not found: $script"
        log_error "Installer script not found: $script"
        echo ""
        gum confirm "Press Enter to continue..." && true
        return 1
    fi
    
    # Convert language name to function name (replace - with _)
    local func_name=$(echo "$choice" | tr '-' '_')
    
    # Source the script and call install function
    if source "$script" && install_${func_name}; then
        log_success "$choice installation completed"
    else
        log_error "$choice installation failed"
    fi
    
    echo ""
    gum confirm "Press Enter to continue..." && true
    return 0
}
