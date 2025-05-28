if [[ "$XDG_CURRENT_DESKTOP" == *"GNOME"* ]]; then
  # close window
  gsettings set org.gnome.desktop.wm.keybindings close "['<Alt>F4']"

  # show desktop = minimize all
  gsettings set org.gnome.desktop.wm.keybindings show-desktop  "['<Super>D']"

  # Reserve slots for custom keybindings
  gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/']"

  # Warp Terminal as a custom keybinding with <Super>t
  gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name 'warp-terminal'
  gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command 'warp-terminal'
  gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding '<Super>t'
else
  echo "Not setting gnome-hotkeys, the current desktop environment is not GNOME."
fi
