#!/bin/bash

# core/user-config.sh
# Manages user configuration (name, email, git setup)

USER_CONFIG_FILE="$CONFIG_DIR/user.conf"

# Ensure config directory exists
ensure_config_dir() {
    if [ ! -d "$CONFIG_DIR" ]; then
        mkdir -p "$CONFIG_DIR"
    fi
}

# Check if user config exists
user_config_exists() {
    [ -f "$USER_CONFIG_FILE" ]
}

# Load user configuration
load_user_config() {
    if user_config_exists; then
        source "$USER_CONFIG_FILE"
        return 0
    else
        return 1
    fi
}

# Save user configuration
save_user_config() {
    local name=$1
    local email=$2
    
    ensure_config_dir
    
    cat > "$USER_CONFIG_FILE" << EOF
# User Configuration for arch-setup
USER_NAME="$name"
USER_EMAIL="$email"
GIT_CONFIGURED=false
CONFIGURED=true
CONFIGURED_AT="$(date '+%Y-%m-%d %H:%M:%S')"
EOF
    
    chmod 600 "$USER_CONFIG_FILE"
}

# Display current configuration
display_user_config() {
    if load_user_config; then
        gum style --border rounded --border-foreground 81 --padding "1 2" --margin "1 0" \
            "$(gum style --foreground 81 --bold 'Current Configuration')" \
            "" \
            "$(gum style --foreground 75 'Name:')  $USER_NAME" \
            "$(gum style --foreground 75 'Email:') $USER_EMAIL" \
            "" \
            "$(gum style --foreground 245 'Configured at:') $(gum style --foreground 245 "$CONFIGURED_AT")"
    fi
}

# Configure user (interactive)
configure_user() {
    clear
    
    gum style --foreground 81 --bold "User Configuration"
    echo ""
    
    # Check if config exists
    if user_config_exists; then
        display_user_config
        echo ""
        
        action=$(gum choose \
            --cursor.foreground 81 \
            --header "Configuration already exists. What would you like to do?" \
            --header.foreground 81 \
            "Edit Configuration" \
            "Keep Current Configuration" \
            "Back to Main Menu")
        
        case "$action" in
            "Edit Configuration")
                # Continue to input
                ;;
            "Keep Current Configuration")
                gum style --foreground 46 "✓ Keeping current configuration"
                sleep 1
                return 0
                ;;
            "Back to Main Menu")
                return 0
                ;;
        esac
        
        echo ""
    fi
    
    # Input user data
    gum style --foreground 75 "Please enter your information:"
    echo ""
    
    name=$(gum input --placeholder "Full Name" --prompt "Name: " --value "${USER_NAME:-}")
    
    if [ -z "$name" ]; then
        gum style --foreground 196 "✗ Name cannot be empty"
        sleep 2
        return 1
    fi
    
    email=$(gum input --placeholder "email@example.com" --prompt "Email: " --value "${USER_EMAIL:-}")
    
    if [ -z "$email" ]; then
        gum style --foreground 196 "✗ Email cannot be empty"
        sleep 2
        return 1
    fi
    
    # Validate email format (basic)
    if ! [[ "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        gum style --foreground 196 "✗ Invalid email format"
        sleep 2
        return 1
    fi
    
    # Confirm
    echo ""
    gum style --border normal --border-foreground 214 --padding "1 2" \
        "$(gum style --foreground 214 'Please confirm:')" \
        "" \
        "Name:  $name" \
        "Email: $email"
    echo ""
    
    if gum confirm "Save this configuration?"; then
        save_user_config "$name" "$email"
        
        clear
        gum style --foreground 46 "✓ Configuration saved successfully!"
        echo ""
        display_user_config
        echo ""
        
        gum style --foreground 75 "Press Enter to continue..."
        read
    else
        gum style --foreground 214 "Configuration not saved"
        sleep 1
    fi
}
