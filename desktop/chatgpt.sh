#!/bin/bash

# desktop/chatgpt.sh
# ChatGPT desktop app installer

install_chatgpt() {
    log_info "Installing ChatGPT..."

    local installer_dir
    local installer_script

    installer_dir=$(mktemp -d) || {
        log_error "Failed to create a temporary directory for the ChatGPT installer"
        return 1
    }
    installer_script="$installer_dir/install-arch.sh"

    if ! curl --proto '=https' --tlsv1.2 -fL -o "$installer_script" \
        "https://persistent.oaistatic.com/codex-app-prod/linux/install-arch.sh"; then
        log_error "Failed to download the ChatGPT installer"
        rm -f "$installer_script"
        rmdir "$installer_dir" 2>/dev/null
        return 1
    fi

    if ! sudo bash "$installer_script"; then
        log_error "ChatGPT installation failed"
        rm -f "$installer_script"
        rmdir "$installer_dir" 2>/dev/null
        return 1
    fi

    if ! rm -f "$installer_script"; then
        log_error "ChatGPT installed, but the installer file could not be deleted: $installer_script"
        return 1
    fi
    rmdir "$installer_dir" 2>/dev/null

    log_success "ChatGPT installed successfully"
    return 0
}
