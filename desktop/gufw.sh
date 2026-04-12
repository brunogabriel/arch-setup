#!/bin/bash

# desktop/gufw.sh
# GUFW firewall GUI installer

install_gufw() {
    log_info "Installing gufw..."

    if ! yay_install "gufw"; then
        return 1
    fi

    log_info "Configuring UFW firewall..."
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    sudo ufw --force enable
    sudo systemctl enable ufw

    log_success "UFW configured and enabled"
    return 0
}
