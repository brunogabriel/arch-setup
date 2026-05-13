#!/bin/bash

# extras/kernel-cleanup.sh
# Cleans up orphaned systemd-boot entries and EFI directories for kernels
# that are no longer installed, then reinstalls current kernels and updates
# the bootloader. Safe to run after kernel upgrades or removals.

install_kernel_cleanup() {
    local efi_dir="/efi"
    local entries_dir="$efi_dir/loader/entries"

    gum style \
        --border rounded \
        --border-foreground 81 \
        --padding "1 2" \
        --bold \
        "Kernel & Boot Entry Cleanup" \
        "" \
        "$(gum style --foreground 75 "Removes orphaned systemd-boot entries and EFI directories")" \
        "$(gum style --foreground 75 "for kernels that are no longer installed on the system")"

    echo ""

    log_info "Starting kernel boot entry cleanup..."

    # ── Acquire sudo credentials upfront ─────────────────────────────────────
    gum style --foreground 81 "→ This script requires sudo — you may be prompted for your password."
    if ! sudo -v; then
        gum style --foreground 196 "✗ sudo authentication failed"
        log_error "sudo -v failed; aborting kernel cleanup"
        return 1
    fi
    echo ""

    # ── Guard: systemd-boot must be the active bootloader ────────────────────
    # bootctl is-installed reads the EFI block device directly and requires
    # root — regular users get "Permission denied" even with the partition mounted.
    if ! command -v bootctl &>/dev/null; then
        gum style --foreground 196 "✗ bootctl not found — systemd-boot is not installed"
        log_error "bootctl not found; skipping kernel cleanup"
        return 1
    fi

    if ! sudo bootctl is-installed &>/dev/null; then
        gum style --foreground 196 "✗ systemd-boot is not installed in the EFI partition"
        log_error "sudo bootctl is-installed returned non-zero; skipping kernel cleanup"
        return 1
    fi

    gum style --foreground 48 "✓ systemd-boot detected"
    echo ""

    # ── Collect current machine ID ────────────────────────────────────────────
    local current_machine_id
    current_machine_id="$(cat /etc/machine-id)"

    gum style --foreground 81 "→ Machine ID: $current_machine_id"
    log_info "Current machine ID: $current_machine_id"
    echo ""

    # ── Detect installed kernels ──────────────────────────────────────────────
    gum style --foreground 81 "→ Detecting installed kernels..."
    log_info "Detecting installed kernels via pacman..."

    local installed_kernels=()

    # Standard Arch kernel: "linux 6.14.3.arch1-1" → "6.14.3-arch1-1"
    if pacman -Q linux &>/dev/null; then
        local ver
        ver="$(pacman -Q linux | awk '{print $2}' | sed 's/\.arch/-arch/')"
        installed_kernels+=("$ver")
        gum style --foreground 75 "  linux  $ver"
        log_info "Found kernel: linux $ver"
    fi

    # LTS kernel: "linux-lts 6.6.87-1" → "6.6.87-1-lts"
    if pacman -Q linux-lts &>/dev/null; then
        local ver_lts
        ver_lts="$(pacman -Q linux-lts | awk '{print $2}')-lts"
        installed_kernels+=("$ver_lts")
        gum style --foreground 75 "  linux-lts  $ver_lts"
        log_info "Found kernel: linux-lts $ver_lts"
    fi

    if [ ${#installed_kernels[@]} -eq 0 ]; then
        gum style --foreground 196 "✗ No kernels detected — aborting to prevent boot breakage"
        log_error "No installed kernels found; aborting cleanup"
        return 1
    fi

    echo ""

    # ── Scan orphaned boot entries ────────────────────────────────────────────
    gum style --foreground 81 "→ Scanning boot entries..."
    log_info "Scanning entries in: $entries_dir"
    echo ""

    local removed_entries=0
    local kept_entries=0

    local old_nullglob
    old_nullglob="$(shopt -p nullglob)"
    shopt -s nullglob

    for file in "$entries_dir"/*.conf; do
        local filename keep
        filename="$(basename "$file")"
        local machine_id="${filename%%-*}"
        keep=false

        if [[ "$machine_id" == "$current_machine_id" ]]; then
            for kernel in "${installed_kernels[@]}"; do
                if [[ "$filename" == *"$kernel"* ]]; then
                    keep=true
                    break
                fi
            done
        fi

        if [[ "$keep" == true ]]; then
            gum style --foreground 48 "  ✓ Keeping:  $filename"
            log_info "Keeping entry: $filename"
            (( kept_entries++ )) || true
        else
            gum style --foreground 214 "  ⚠ Removing: $filename"
            log_info "Removing entry: $filename"
            if ! sudo rm -f "$file"; then
                gum style --foreground 196 "    ✗ Failed to remove: $filename"
                log_error "Failed to remove entry: $file"
            else
                (( removed_entries++ )) || true
            fi
        fi
    done

    eval "$old_nullglob"

    echo ""
    gum style --foreground 75 "  Entries kept: $kept_entries  |  Would remove: $removed_entries"
    echo ""

    # ── Scan orphaned EFI machine-ID directories ──────────────────────────────
    gum style --foreground 81 "→ Scanning EFI directories for orphaned machine IDs..."
    log_info "Scanning EFI directory: $efi_dir"
    echo ""

    local removed_dirs=0

    for dir in "$efi_dir"/*/; do
        [ -d "$dir" ] || continue

        local dirname
        dirname="$(basename "$dir")"

        if [[ "$dirname" =~ ^[a-f0-9]{32}$ ]] && [[ "$dirname" != "$current_machine_id" ]]; then
            gum style --foreground 214 "  ⚠ Removing EFI dir: $dirname"
            log_info "Removing orphaned EFI directory: $dir"
            if ! sudo rm -rf "$dir"; then
                gum style --foreground 196 "    ✗ Failed to remove: $dir"
                log_error "Failed to remove EFI directory: $dir"
            else
                (( removed_dirs++ )) || true
            fi
        fi
    done

    if [ "$removed_dirs" -eq 0 ]; then
        gum style --foreground 48 "  ✓ No orphaned EFI directories found"
        log_info "No orphaned EFI directories to remove"
    fi

    echo ""

    # ── Reinstall kernels + update bootloader only if something was removed ───
    local total_removed=$(( removed_entries + removed_dirs ))

    if [ "$total_removed" -gt 0 ]; then
        gum style --foreground 81 "→ Reinstalling kernel images..."
        log_info "Running: sudo reinstall-kernels"

        if ! sudo reinstall-kernels; then
            gum style --foreground 196 "✗ reinstall-kernels failed"
            log_error "reinstall-kernels exited with error"
            return 1
        fi

        gum style --foreground 48 "✓ Kernels reinstalled"
        log_success "Kernel images reinstalled"
        echo ""

        gum style --foreground 81 "→ Updating systemd-boot..."
        log_info "Running: sudo bootctl update"

        if ! sudo bootctl update; then
            gum style --foreground 196 "✗ bootctl update failed"
            log_error "bootctl update exited with error"
            return 1
        fi

        gum style --foreground 48 "✓ systemd-boot updated"
        log_success "systemd-boot updated"
        echo ""
    else
        gum style --foreground 75 "  Nothing removed — skipping reinstall-kernels and bootctl update"
        log_info "No changes made; skipping reinstall-kernels and bootctl update"
        echo ""
    fi

    # ── Summary ───────────────────────────────────────────────────────────────
    gum style \
        --border rounded \
        --border-foreground 48 \
        --padding "1 2" \
        "$(gum style --foreground 48 --bold "✓ Kernel cleanup complete!")" \
        "" \
        "$(gum style --foreground 75 "Entries removed:     $removed_entries")" \
        "$(gum style --foreground 75 "EFI dirs removed:    $removed_dirs")" \
        "" \
        "$(gum style --foreground 81 "Active boot entries:")" \
        "$(bootctl list 2>/dev/null | grep 'title' || echo '  (none)')"

    log_success "Kernel boot entry cleanup finished"

    return 0
}
