yay -S --needed gufw --noconfirm
yay -S --needed ufw-docker --noconfirm

gum style --foreground 212 "Confuguring UFW firewall default rules..."

sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow Docker containers to use DNS on host
sudo ufw allow in proto udp from 172.16.0.0/12 to 172.17.0.1 port 53 comment 'allow-docker-dns'

# Turn on the firewall
sudo ufw --force enable

# Enable UFW systemd service to start on boot
sudo systemctl enable ufw

# Turn on Docker protections
sudo ufw-docker install
sudo ufw reload