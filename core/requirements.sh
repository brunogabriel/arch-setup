#!/bin/bash

# core/requirements.sh
# Check and install required dependencies for arch-setup CLI

# Update pacman database (once per day)
# Checks last update timestamp and only updates if > 24 hours
update_pacman_once_daily() {
    local current_time=$(date +%s)
    local last_update=0
    
    # Create state file if it doesn't exist
    if [ ! -f "$STATE_FILE" ]; then
        mkdir -p "$CONFIG_DIR"
        echo "LAST_PACMAN_UPDATE=0" > "$STATE_FILE"
    fi
    
    # Read last update time
    if [ -f "$STATE_FILE" ]; then
        source "$STATE_FILE"
        last_update=${LAST_PACMAN_UPDATE:-0}
    fi
    
    # Calculate time difference (24 hours = 86400 seconds)
    local time_diff=$((current_time - last_update))
    local hours_diff=$((time_diff / 3600))
    
    if [ $time_diff -lt 86400 ]; then
        gum style --foreground 75 "✓ Pacman already updated today ($hours_diff hours ago)"
        log_info "Pacman already updated today ($hours_diff hours ago), skipping update"
        return 0
    fi
    
    # Update pacman
    gum style --foreground 81 "→ Updating pacman database..."
    log_info "Updating pacman database (last update: $hours_diff hours ago)..."
    
    if sudo pacman -Syyuu --noconfirm; then
        gum style --foreground 48 "✓ Pacman updated successfully"
        log_success "Pacman updated successfully"
        
        # Save current timestamp
        echo "LAST_PACMAN_UPDATE=$current_time" > "$STATE_FILE"
        log_info "Saved update timestamp: $current_time"
        
        return 0
    else
        gum style --foreground 196 "✗ Failed to update pacman"
        log_error "Failed to update pacman"
        return 1
    fi
}

# Check and install requirements
check_requirements() {
    echo -e "${COLOR_INFO}Checking requirements...${COLOR_RESET}"
    log_info "Checking requirements..."
    
    # Check if gum is installed
    if ! command -v gum &> /dev/null; then
        echo -e "${COLOR_WARNING}⚠ gum is not installed${COLOR_RESET}"
        echo -e "${COLOR_INFO}Installing gum...${COLOR_RESET}"
        log_warning "gum is not installed"
        log_info "Installing gum..."
        
        if sudo pacman -S --needed --noconfirm gum; then
            echo -e "${COLOR_SUCCESS}✓ gum installed successfully${COLOR_RESET}"
            log_success "gum installed successfully"
        else
            echo -e "${COLOR_ERROR}✗ Failed to install gum${COLOR_RESET}"
            echo -e "${COLOR_ERROR}Please install gum manually: sudo pacman -S gum${COLOR_RESET}"
            log_error "Failed to install gum"
            exit 1
        fi
    else
        echo -e "${COLOR_SUCCESS}✓ gum is installed${COLOR_RESET}"
        log_info "gum is already installed"
    fi
    
    echo ""
    sleep 1
}

# Check and install installation requirements (for terminal/desktop packages)
# This includes: curl, git, unzip, base-devel, yay
# Also updates pacman database (once per day)
check_installation_requirements() {
    log_info "Starting installation requirements check..."
    
    gum style \
        --border rounded \
        --border-foreground 81 \
        --padding "1 2" \
        --bold \
        "Checking Installation Requirements"
    
    echo ""
    
    # Update pacman (smart - once per day)
    if ! update_pacman_once_daily; then
        return 1
    fi
    
    echo ""
    
    # Check and install required packages
    for package in "${REQUIRED_INSTALLATION_PACKAGES[@]}"; do
        if ! command -v "$package" &> /dev/null && ! pacman -Qi "$package" &> /dev/null; then
            gum style --foreground 214 "⚠ $package is not installed"
            gum style --foreground 81 "→ Installing $package..."
            log_warning "$package is not installed"
            log_info "Installing $package..."
            
            if sudo pacman -S --needed --noconfirm "$package"; then
                gum style --foreground 48 "✓ $package installed successfully"
                log_success "$package installed successfully"
            else
                gum style --foreground 196 "✗ Failed to install $package"
                log_error "Failed to install $package"
                return 1
            fi
        else
            gum style --foreground 48 "✓ $package is installed"
            log_info "$package is already installed"
        fi
    done
    
    echo ""
    
    # Check if yay is installed
    if ! command -v yay &> /dev/null; then
        gum style --foreground 214 "⚠ yay (AUR helper) is not installed"
        gum style --foreground 81 "→ Installing yay..."
        log_warning "yay (AUR helper) is not installed"
        log_info "Installing yay via pacman..."
        
        # Install yay via pacman (available in Manjaro repos)
        if sudo pacman -S --needed --noconfirm yay; then
            gum style --foreground 48 "✓ yay installed successfully"
            log_success "yay installed successfully"
        else
            gum style --foreground 196 "✗ Failed to install yay"
            log_error "Failed to install yay via pacman"
            return 1
        fi
    else
        gum style --foreground 48 "✓ yay is installed"
        log_info "yay is already installed"
    fi
    
    echo ""
    gum style --foreground 48 --bold "✓ All installation requirements are ready"
    log_success "All installation requirements are ready"
    echo ""
    sleep 2
    
    return 0
}
