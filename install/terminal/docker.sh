yay -S --needed docker docker-compose --noconfirm

sudo usermod -aG docker ${USER}

sudo mkdir -p /etc/docker

sudo systemctl restart docker.service

sudo systemctl enable docker.service
