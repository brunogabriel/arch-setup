#!/bin/bash

# desktop/set-gnome-hotkeys.sh
# GNOME desktop hotkeys configuration

install_set_gnome_hotkeys() {
    log_info "Configuring GNOME hotkeys..."
    
    # Check if running GNOME
    if [[ "$XDG_CURRENT_DESKTOP" != *"GNOME"* ]]; then
        log_warning "Not running GNOME desktop environment - skipping hotkey configuration"
        return 0
    fi
    
    # Close window with Alt+F4
    gsettings set org.gnome.desktop.wm.keybindings close "['<Alt>F4']"
    
    # Show desktop (minimize all) with Super+D
    gsettings set org.gnome.desktop.wm.keybindings show-desktop "['<Super>D']"
    
    # Reserve custom keybinding slot
    gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/']"
    
    # Set Warp Terminal to Super+T
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name 'warp-terminal'
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command 'warp-terminal'
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding '<Super>t'
    
    log_success "GNOME hotkeys configured successfully"
    return 0
}
