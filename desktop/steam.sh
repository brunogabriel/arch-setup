#!/bin/bash

# desktop/steam.sh
# Steam gaming platform installer with auto-launch

install_steam() {
    log_info "Installing Steam..."
    
    if ! yay_install "steam"; then
        return 1
    fi
    
    # Launch Steam in background to complete initial setup
    log_info "Launching Steam for initial setup..."
    setsid gtk-launch steam >/dev/null 2>&1 &
    
    log_success "Steam installed and launched for initial setup"
    return 0
}
