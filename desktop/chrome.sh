#!/bin/bash

# desktop/chrome.sh
# Google Chrome browser installer

install_chrome() {
    log_info "Installing Google Chrome..."
    
    if ! yay_install "google-chrome"; then
        return 1
    fi
    
    # Add Chrome environment variable to zsh if modular structure exists
    if check_zshrc_structure 2>/dev/null; then
        append_to_zsh_module "shell" \
            'export CHROME_EXECUTABLE="/usr/bin/google-chrome-stable"' \
            "Google Chrome - Browser executable path"
    fi
    
    return 0
}
