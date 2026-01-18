#!/bin/bash

# terminal/btop.sh
# Install and configure btop - Resource monitor

# Check if btop is already installed
is_btop_installed() {
    command -v btop &> /dev/null
}

# Install btop
install_btop() {
    log_info "Starting btop installation..."
    
    # Check if already installed
    if is_btop_installed; then
        gum style --foreground 75 "  btop is already installed"
        log_info "btop is already installed, skipping"
        return 0
    fi
    
    # Install btop via yay
    if yay -S --needed --noconfirm btop; then
        log_success "btop installed successfully"
        
        # Configure btop (optional)
        configure_btop
        
        return 0
    else
        log_error "Failed to install btop"
        return 1
    fi
}

# Configure btop (optional)
configure_btop() {
    local config_dir="$HOME/.config/btop"
    local config_file="$config_dir/btop.conf"
    
    # Create config directory if it doesn't exist
    if [ ! -d "$config_dir" ]; then
        mkdir -p "$config_dir"
        log_info "Created btop config directory: $config_dir"
    fi
    
    # Check if config already exists
    if [ -f "$config_file" ]; then
        log_info "btop config already exists, skipping configuration"
        return 0
    fi
    
    # Create basic config (optional - btop works fine with defaults)
    # You can customize this based on your preferences
    cat > "$config_file" << 'EOF'
# btop config

#* Color theme
color_theme = "Default"

#* Update time in milliseconds
update_ms = 2000

#* Show CPU temperature
show_cpu_temps = True

#* Show disk IO
show_disks = True

#* Show network stats
net_download = True
net_upload = True
EOF
    
    log_success "btop configured with default settings"
    return 0
}

# Uninstall btop (for future use)
uninstall_btop() {
    if ! is_btop_installed; then
        gum style --foreground 214 "btop is not installed"
        return 0
    fi
    
    if yay -Rns --noconfirm btop; then
        gum style --foreground 48 "✓ btop uninstalled successfully"
        log_success "btop uninstalled successfully"
        return 0
    else
        gum style --foreground 196 "✗ Failed to uninstall btop"
        log_error "Failed to uninstall btop"
        return 1
    fi
}
