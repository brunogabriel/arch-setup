gum style --foreground 212 "Installing desktop applications..."

# desktop apps
for desktop in ./install/desktop/*.sh; do source $desktop; done

gum style --foreground 212 "Desktop applications installed."