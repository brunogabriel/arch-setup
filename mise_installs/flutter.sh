#!/bin/bash

# mise_installs/flutter.sh
# Flutter SDK installation via mise

install_flutter() {
    log_info "Installing Flutter via mise..."
    
    # Check if mise is installed
    if ! command -v mise &> /dev/null; then
        gum style --foreground 196 "✗ mise is not installed!"
        gum style --foreground 214 "→ Please install Terminal Tools first (Option 3)"
        log_error "mise not installed - cannot install Flutter"
        return 1
    fi
    
    # Ask user for version
    gum style \
        --border rounded \
        --border-foreground 81 \
        --padding "1 2" \
        "Flutter Installation" \
        "" \
        "$(gum style --foreground 75 "Choose version to install:")"
    
    echo ""
    
    local version_choice=$(gum choose \
        --cursor.foreground 81 \
        --selected.foreground 48 \
        "latest (Recommended)" \
        "Custom version")
    
    local version=""
    
    case "$version_choice" in
        "latest (Recommended)")
            version="latest"
            ;;
        "Custom version")
            version=$(gum input \
                --placeholder "e.g., 3.16.0, stable, beta" \
                --prompt "Version: ")
            
            if [ -z "$version" ]; then
                gum style --foreground 196 "✗ No version provided"
                log_error "No Flutter version provided"
                return 1
            fi
            ;;
        *)
            gum style --foreground 196 "✗ Invalid choice"
            return 1
            ;;
    esac
    
    echo ""
    gum style --foreground 81 "→ Installing Flutter@$version via mise..."
    log_info "Installing Flutter@$version via mise..."
    
    # Install Flutter via mise
    if mise use -g flutter@"$version" 2>&1 | tee -a "$LOG_FILE"; then
        echo ""
        gum style --foreground 48 "✓ Flutter@$version installed successfully"
        log_success "Flutter@$version installed via mise"
        
        # Add pub-cache to PATH in ~/.shell
        smart_append_to_zsh "shell" \
            'export PATH="$PATH":"$HOME/.pub-cache/bin"' \
            "Flutter - pub-cache binaries"
        
        # Show installed version
        echo ""
        if command -v flutter &> /dev/null; then
            local flutter_version=$(flutter --version 2>/dev/null | head -n1)
            gum style --foreground 75 "Installed: $flutter_version"
        fi
        
        return 0
    else
        echo ""
        gum style --foreground 196 "✗ Failed to install Flutter@$version"
        log_error "Failed to install Flutter@$version"
        return 1
    fi
}
