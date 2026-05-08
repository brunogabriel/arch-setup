#!/bin/bash

# desktop/plasma-login-manager.sh
# Plasma login manager installer (replaces SDDM)

install_plasma_login_manager() {
    log_info "Installing plasma-login-manager..."

    # Check if sddm is installed and active
    if systemctl is-active sddm &> /dev/null; then
        gum style --foreground 214 "⚠ SDDM is active, switching to plasma-login-manager..."

        # Install plasma-login-manager
        if ! sudo pacman -Syu --noconfirm plasma-login-manager; then
            log_error "Failed to install plasma-login-manager"
            return 1
        fi

        # Disable SDDM and enable plasmalogin
        sudo systemctl disable sddm
        sudo systemctl enable plasmalogin

        # Remove SDDM packages
        if ! sudo pacman -R --noconfirm sddm-kcm sddm; then
            log_warning "Failed to remove some SDDM packages"
        fi

        gum style --foreground 48 "✓ SDDM replaced with plasma-login-manager"
        log_success "SDDM replaced with plasma-login-manager"
    else
        gum style --foreground 75 "SDDM not active, installing plasma-login-manager directly..."

        if ! sudo pacman -Syu --noconfirm plasma-login-manager; then
            log_error "Failed to install plasma-login-manager"
            return 1
        fi

        gum style --foreground 48 "✓ plasma-login-manager installed"
        log_success "plasma-login-manager installed"
    fi

    return 0
}
