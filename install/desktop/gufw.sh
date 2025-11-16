yay -S --needed gufw --noconfirm

gum style --foreground 212 "Confuguring UFW firewall default rules..."

sudo ufw default deny incoming
sudo ufw default allow outgoing

sudo ufw --force enable
sudo systemctl enable ufw