#!/bin/bash

# core/install-utils.sh
# Utilities for installing and managing packages

# Check if a package/command is installed
# Args:
#   $1 - package name or command name
is_installed() {
    local package=$1
    command -v "$package" &> /dev/null
}

# Install package(s) via pacman (official repos)
# Args:
#   $@ - one or more package names
# Returns:
#   0 on success, 1 on failure
pacman_install() {
    local packages=("$@")
    local success_count=0
    local fail_count=0

    for package in "${packages[@]}"; do
        log_info "Starting $package installation..."

        if is_installed "$package"; then
            gum style --foreground 75 "  $package is already installed"
            log_info "$package is already installed"
            apply_app_theme "$package"
            ((success_count++))
            continue
        fi

        gum style --foreground 81 "→ Installing $package..."
        if sudo pacman -S --needed --noconfirm "$package"; then
            gum style --foreground 48 "✓ $package installed successfully"
            log_success "$package installed successfully"
            apply_app_theme "$package"
            ((success_count++))
        else
            gum style --foreground 196 "✗ Failed to install $package"
            log_error "Failed to install $package"
            ((fail_count++))
        fi
        echo ""
    done

    [ ${#packages[@]} -gt 1 ] && log_info "Installation completed: $success_count success, $fail_count failed"
    return $fail_count
}

# Uninstall package via pacman
# Args:
#   $1 - package name
pacman_uninstall() {
    local package=$1

    if ! is_installed "$package"; then
        gum style --foreground 214 "$package is not installed"
        log_info "$package is not installed, nothing to uninstall"
        return 0
    fi

    gum style --foreground 81 "→ Uninstalling $package..."
    if sudo pacman -Rns --noconfirm "$package"; then
        gum style --foreground 48 "✓ $package uninstalled successfully"
        log_success "$package uninstalled successfully"
        return 0
    else
        gum style --foreground 196 "✗ Failed to uninstall $package"
        log_error "Failed to uninstall $package"
        return 1
    fi
}

# Install package(s) via yay (AUR)
# Args:
#   $@ - one or more package names
# Returns:
#   0 on success, 1 on failure
yay_install() {
    local packages=("$@")
    local success_count=0
    local fail_count=0

    for package in "${packages[@]}"; do
        log_info "Starting $package installation..."

        if is_installed "$package"; then
            gum style --foreground 75 "  $package is already installed"
            log_info "$package is already installed"
            apply_app_theme "$package"
            ((success_count++))
            continue
        fi

        gum style --foreground 81 "→ Installing $package..."
        if yay -S --needed --noconfirm "$package"; then
            gum style --foreground 48 "✓ $package installed successfully"
            log_success "$package installed successfully"
            apply_app_theme "$package"
            ((success_count++))
        else
            gum style --foreground 196 "✗ Failed to install $package"
            log_error "Failed to install $package"
            ((fail_count++))
        fi
        echo ""
    done

    [ ${#packages[@]} -gt 1 ] && log_info "Installation completed: $success_count success, $fail_count failed"
    return $fail_count
}

# Uninstall package via yay
# Args:
#   $1 - package name
yay_uninstall() {
    local package=$1

    if ! is_installed "$package"; then
        gum style --foreground 214 "$package is not installed"
        log_info "$package is not installed, nothing to uninstall"
        return 0
    fi

    gum style --foreground 81 "→ Uninstalling $package..."
    if yay -Rns --noconfirm "$package"; then
        gum style --foreground 48 "✓ $package uninstalled successfully"
        log_success "$package uninstalled successfully"
        return 0
    else
        gum style --foreground 196 "✗ Failed to uninstall $package"
        log_error "Failed to uninstall $package"
        return 1
    fi
}
