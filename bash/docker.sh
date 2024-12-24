#!\bin\bash

###Déclaration des couleurs
RED='\033[0;31m'
BLUE='\033[1;34m'
NC='\033[0m'

###Installation de Docker
sudo dnf config-manager --add-repo=https://download.docker.com/linux/fedora/docker-ce.repo
sudo dnf install docker-ce docker-ce-cli containerd.io
sudo usermod -aG docker $USER
newgrp docker
systemctl enable --now docker