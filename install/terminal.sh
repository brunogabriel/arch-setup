echo "Installing terminal tools..."

# base
sudo pacman -Syyuu --noconfirm
sudo pacman -S curl git unzip --noconfirm
sudo pacman -S --needed base-devel --noconfirm

# yay
if ! command -v yay >/dev/null 2>&1; then
  git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si --noconfirm
  cd .. && rm -rf yay
  yay -Syu --noconfirm
fi

# terminal tools
for installer in ./install/terminal/*.sh; do source $installer; done

echo "Finished installing all terminal tools"