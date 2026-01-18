#!/bin/bash

# core/themes.sh
# Theme management system

# Get available themes
get_available_themes() {
    local themes=()
    
    if [ -d "$INSTALL_DIR/themes" ]; then
        for theme_dir in "$INSTALL_DIR/themes"/*; do
            if [ -d "$theme_dir" ]; then
                local theme_name=$(basename "$theme_dir")
                themes+=("$theme_name")
            fi
        done
    fi
    
    echo "${themes[@]}"
}

# Get current theme from user config
get_current_theme() {
    local current_theme="moonlight" # Default
    
    if [ -f "$USER_CONFIG_FILE" ]; then
        source "$USER_CONFIG_FILE"
        current_theme="${SELECTED_THEME:-moonlight}"
    fi
    
    echo "$current_theme"
}

# Set theme in user config
set_theme() {
    local theme=$1
    
    if [ ! -f "$USER_CONFIG_FILE" ]; then
        gum style --foreground 196 "✗ User config not found. Please configure user first."
        log_error "Cannot set theme: user config not found"
        return 1
    fi
    
    # Check if theme exists
    if [ ! -d "$INSTALL_DIR/themes/$theme" ]; then
        gum style --foreground 196 "✗ Theme not found: $theme"
        log_error "Theme not found: $theme"
        return 1
    fi
    
    # Update or add SELECTED_THEME in config
    if grep -q "^SELECTED_THEME=" "$USER_CONFIG_FILE"; then
        sed -i "s/^SELECTED_THEME=.*/SELECTED_THEME=\"$theme\"/" "$USER_CONFIG_FILE"
    else
        echo "SELECTED_THEME=\"$theme\"" >> "$USER_CONFIG_FILE"
    fi
    
    log_success "Theme set to: $theme"
    return 0
}

# Select theme interactively
select_theme() {
    local available_themes=($(get_available_themes))
    local current_theme=$(get_current_theme)
    
    if [ ${#available_themes[@]} -eq 0 ]; then
        gum style --foreground 214 "⚠ No themes available"
        log_warning "No themes found in themes/ directory"
        return 1
    fi
    
    gum style \
        --border rounded \
        --border-foreground 81 \
        --padding "1 2" \
        --bold \
        "Theme Selection"
    
    echo ""
    gum style --foreground 75 "Current theme: $(gum style --foreground 81 --bold "$current_theme")"
    echo ""
    
    # Show theme selection menu
    local selected_theme=$(gum choose \
        --cursor.foreground 81 \
        --header "Select a theme:" \
        --header.foreground 81 \
        "${available_themes[@]}")
    
    if [ -z "$selected_theme" ]; then
        gum style --foreground 214 "No theme selected"
        log_info "User cancelled theme selection"
        return 0
    fi
    
    # Set the theme
    if set_theme "$selected_theme"; then
        gum style --foreground 48 "✓ Theme set to: $selected_theme"
        echo ""
        gum style --foreground 214 "Note: You may need to reinstall applications to apply the new theme."
        echo ""
    else
        gum style --foreground 196 "✗ Failed to set theme"
        return 1
    fi
    
    return 0
}

# Copy theme files for a specific application
# Args:
#   $1 - app name (e.g., "btop")
#   $2 - destination directory (e.g., "$HOME/.config/btop")
apply_theme_for_app() {
    local app_name=$1
    local dest_dir=$2
    local theme=$(get_current_theme)
    local theme_source="$INSTALL_DIR/themes/$theme/$app_name"
    
    log_info "Applying $theme theme for $app_name..."
    
    # Check if theme has files for this app
    if [ ! -d "$theme_source" ]; then
        log_warning "No theme files found for $app_name in theme $theme"
        return 0  # Not an error, just no theme available
    fi
    
    # Create destination directory if it doesn't exist
    mkdir -p "$dest_dir"
    
    # Create themes subdirectory if app needs it (e.g., btop/themes/)
    if [ -d "$theme_source/themes" ]; then
        mkdir -p "$dest_dir/themes"
    fi
    
    # Copy all theme files
    if cp -r "$theme_source"/* "$dest_dir/"; then
        log_success "Applied $theme theme for $app_name"
        gum style --foreground 48 "  ✓ Theme applied: $theme"
        return 0
    else
        log_error "Failed to apply theme for $app_name"
        return 1
    fi
}

# Apply current theme to all installed applications
# Detects which apps are installed and applies theme to each
apply_current_theme() {
    local theme=$(get_current_theme)
    
    gum style \
        --border rounded \
        --border-foreground 81 \
        --padding "1 2" \
        --bold \
        "Applying Theme: $theme"
    
    echo ""
    log_info "Applying theme $theme to all installed applications..."
    
    local apps_updated=0
    local apps_skipped=0
    
    # Check and apply theme for btop
    if command -v btop &> /dev/null; then
        gum style --foreground 81 "→ Applying theme to btop..."
        if apply_theme_for_app "btop" "$HOME/.config/btop"; then
            ((apps_updated++))
        else
            ((apps_skipped++))
        fi
    else
        log_info "btop not installed, skipping"
        ((apps_skipped++))
    fi
    
    # Add more apps here as you implement them
    # Example:
    # if command -v alacritty &> /dev/null; then
    #     gum style --foreground 81 "→ Applying theme to alacritty..."
    #     if apply_theme_for_app "alacritty" "$HOME/.config/alacritty"; then
    #         ((apps_updated++))
    #     else
    #         ((apps_skipped++))
    #     fi
    # fi
    
    echo ""
    
    # Summary
    gum style \
        --border rounded \
        --border-foreground 81 \
        --padding "1 2" \
        "Theme Application Summary" \
        "" \
        "$(gum style --foreground 48 "✓ Apps updated: $apps_updated")" \
        "$(gum style --foreground 245 "○ Apps skipped: $apps_skipped")"
    
    log_info "Theme application completed: $apps_updated updated, $apps_skipped skipped"
    
    echo ""
    return 0
}

# Apply theme for a specific app (called by install utilities)
# Args:
#   $1 - app name (e.g., "btop", "alacritty")
apply_app_theme() {
    local app_name=$1
    
    # Define config directories for each app
    case "$app_name" in
        btop)
            apply_theme_for_app "btop" "$HOME/.config/btop"
            ;;
        alacritty)
            apply_theme_for_app "alacritty" "$HOME/.config/alacritty"
            ;;
        neovim|nvim)
            apply_theme_for_app "neovim" "$HOME/.config/nvim"
            ;;
        *)
            log_info "No theme configuration defined for $app_name"
            return 0
            ;;
    esac
}

# Theme management menu
manage_themes() {
    gum style \
        --border rounded \
        --border-foreground 81 \
        --padding "1 2" \
        --bold \
        "Theme Management"
    
    echo ""
    
    local current_theme=$(get_current_theme)
    gum style --foreground 75 "Current theme: $(gum style --foreground 81 --bold "$current_theme")"
    
    echo ""
    
    local choice=$(gum choose \
        --cursor.foreground 81 \
        --header "What would you like to do?" \
        --header.foreground 81 \
        "Change Theme" \
        "View Current Theme" \
        "Back to Main Menu")
    
    case "$choice" in
        "Change Theme")
            select_theme
            ;;
        "View Current Theme")
            gum style \
                --border rounded \
                --border-foreground 81 \
                --padding "1 2" \
                "Current Theme" \
                "" \
                "$(gum style --foreground 81 --bold "$current_theme")"
            ;;
        *)
            return 0
            ;;
    esac
    
    echo ""
    gum confirm "Press Enter to continue..." && true
}
