echo "Installing terminal tools..."

# base
sudo pacman -Syyuu --noconfirm
sudo pacman -S curl git unzip --noconfirm
sudo pacman -S --needed base-devel --noconfirm

# yay
sudo pacman -S --needed yay --noconfirm

# terminal tools
for installer in ./install/terminal/*.sh; do source $installer; done

echo "Finished installing all terminal tools"