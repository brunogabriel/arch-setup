gum style --foreground 212 "Installing terminal tools..."


# base
sudo pacman -Syyuu --noconfirm
sudo pacman -S curl git unzip --noconfirm
sudo pacman -S --needed base-devel --noconfirm

# yay
sudo pacman -S --needed yay --noconfirm

# terminal tools
for installer in ./install/terminal/*.sh; do
    tool_name=$(basename "$installer" .sh)
    
    if source "$installer" 2>&1; then
        gum style --foreground 46 "✓ $tool_name installed successfully"
    else
        gum style --foreground 196 "✗ Error installing $tool_name"
    fi
done

gum style --foreground 212 "Terminal tools installation completed."