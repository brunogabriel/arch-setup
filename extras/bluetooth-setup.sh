#!/bin/bash

# extras/bluetooth-setup.sh
# Enable and start the Bluetooth systemd service

install_bluetooth_setup() {
    gum style \
        --border rounded \
        --border-foreground 81 \
        --padding "1 2" \
        --bold \
        "Enable & Setup Bluetooth" \
        "" \
        "$(gum style --foreground 75 "Starts the Bluetooth service for the current session")" \
        "$(gum style --foreground 75 "and enables it to start automatically on every boot")"

    echo ""

    log_info "Starting Bluetooth setup..."

    # Acquire sudo credentials upfront
    gum style --foreground 81 "→ This script requires sudo — you may be prompted for your password."
    if ! sudo -v; then
        gum style --foreground 196 "✗ sudo authentication failed"
        log_error "sudo authentication failed"
        return 1
    fi
    echo ""

    # Start bluetooth service
    gum style --foreground 81 "→ Starting bluetooth service..."
    log_info "Running: sudo systemctl start bluetooth"

    if ! sudo systemctl start bluetooth; then
        gum style --foreground 196 "✗ Failed to start bluetooth service"
        log_error "sudo systemctl start bluetooth failed"
        return 1
    fi

    gum style --foreground 48 "✓ Bluetooth service started"
    echo ""

    # Enable bluetooth service
    gum style --foreground 81 "→ Enabling bluetooth service on boot..."
    log_info "Running: sudo systemctl enable bluetooth"

    if ! sudo systemctl enable bluetooth; then
        gum style --foreground 196 "✗ Failed to enable bluetooth service"
        log_error "sudo systemctl enable bluetooth failed"
        return 1
    fi

    gum style --foreground 48 "✓ Bluetooth service enabled"
    echo ""

    # Success summary
    gum style \
        --border rounded \
        --border-foreground 48 \
        --padding "1 2" \
        "$(gum style --foreground 48 --bold "✓ Bluetooth is ready!")" \
        "" \
        "$(gum style --foreground 75 "Current session:")" \
        "$(gum style --foreground 81 "  Started — active until reboot")" \
        "" \
        "$(gum style --foreground 75 "After reboot:")" \
        "$(gum style --foreground 81 "  Enabled — will start automatically")"

    log_success "Bluetooth setup completed successfully"

    return 0
}
