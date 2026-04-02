#!/bin/bash

# extras/bluetooth-rtl8761b.sh
# Realtek RTL8761B Bluetooth firmware fix for Xbox controller connectivity
#
# Installs bundled firmware to /lib/firmware/updates/rtl_bt/ so it takes
# priority over the system firmware without being overwritten by package
# manager updates. No internet connection required.
#
# Firmware source: Windows Update Catalog
#   cab: c1f14a17-4aed-40ff-85cb-7710d0244f42_(...).cab
#   file: rtl8761b_mp_chip_bt40_fw_asic_rom_patch_new.dat
#   processed with: xz -C crc32

install_bluetooth_rtl8761b() {
    local fw_src="$INSTALL_DIR/extras/firmware/rtl8761bu_fw.bin.xz"
    local fw_dest="/lib/firmware/updates/rtl_bt/rtl8761bu_fw.bin.xz"
    local fw_dest_dir="/lib/firmware/updates/rtl_bt"

    gum style \
        --border rounded \
        --border-foreground 81 \
        --padding "1 2" \
        --bold \
        "Realtek RTL8761B Bluetooth Firmware Fix" \
        "" \
        "$(gum style --foreground 75 "Fixes connectivity issues with Xbox controllers")" \
        "$(gum style --foreground 75 "and other Bluetooth devices using RTL8761B chip")"

    echo ""

    log_info "Starting RTL8761B Bluetooth firmware fix..."

    # Sanity check: bundled firmware must exist
    if [ ! -f "$fw_src" ]; then
        gum style --foreground 196 "✗ Bundled firmware not found: $fw_src"
        log_error "Firmware file missing from repo: $fw_src"
        return 1
    fi

    # Check if firmware override already exists
    if [ -f "$fw_dest" ]; then
        gum style --foreground 48 "✓ Firmware override already installed at:"
        gum style --foreground 81 "  $fw_dest"
        log_info "RTL8761B firmware override already present"
        echo ""

        if ! gum confirm "Reinstall / update firmware?"; then
            gum style --foreground 214 "⚠ Skipped"
            return 0
        fi
        echo ""
    fi

    # Create override firmware directory
    gum style --foreground 81 "→ Creating firmware override directory..."
    log_info "Creating: $fw_dest_dir"

    if ! sudo mkdir -p "$fw_dest_dir"; then
        gum style --foreground 196 "✗ Failed to create directory: $fw_dest_dir"
        log_error "sudo mkdir -p failed for: $fw_dest_dir"
        return 1
    fi

    gum style --foreground 48 "✓ Directory ready: $fw_dest_dir"
    echo ""

    # Copy bundled firmware to destination
    gum style --foreground 81 "→ Installing firmware..."
    log_info "Copying: $fw_src -> $fw_dest"

    if ! sudo cp "$fw_src" "$fw_dest"; then
        gum style --foreground 196 "✗ Failed to copy firmware"
        log_error "sudo cp failed: $fw_src -> $fw_dest"
        return 1
    fi

    gum style --foreground 48 "✓ Firmware installed: $fw_dest"
    echo ""

    # Success summary
    gum style \
        --border rounded \
        --border-foreground 48 \
        --padding "1 2" \
        "$(gum style --foreground 48 --bold "✓ RTL8761B firmware fix applied!")" \
        "" \
        "$(gum style --foreground 75 "Firmware location:")" \
        "$(gum style --foreground 81 "  $fw_dest")" \
        "" \
        "$(gum style --foreground 214 "⚠ A reboot is required to load the new firmware.")" \
        "" \
        "$(gum style --foreground 75 "After rebooting, verify with:")" \
        "$(gum style --foreground 81 "  sudo dmesg | grep 'RTL: fw version'")"

    log_success "RTL8761B Bluetooth firmware fix installed successfully"

    return 0
}
