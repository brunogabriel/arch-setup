#!/bin/bash

# desktop/chrome.sh
# Google Chrome browser installer

install_chrome() {
    log_info "Installing Google Chrome..."
    
    if ! yay_install "google-chrome"; then
        return 1
    fi
    
    # Add Chrome environment variable to zsh
    smart_append_to_zsh "shell" \
        'export CHROME_EXECUTABLE="/usr/bin/google-chrome-stable"' \
        "Google Chrome - Browser executable path"
    
    return 0
}
