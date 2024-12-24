#!\bin\bash

###Déclaration des couleurs
RED='\033[0;31m'
BLUE='\033[1;34m'
NC='\033[0m'

#Installation d'incus
#sudo dnf copr enable lxc/incus
sudo dnf copr enable ganto/lxc4 -y
sudo dnf install lxc -y
sudo dnf update lxc -y
sudo dnf install incus -y
sudo usermod -a -G incus-admin $USER
echo "root:1000000:1000000000" | sudo tee -a /etc/subuid > /dev/null
echo "root:1000000:1000000000" | sudo tee -a /etc/subgid > /dev/null
newgrp incus-admin </dev/null
systemctl enable --now incus
incus admin init
sudo firewall-cmd --zone=trusted --change-interface=incusbr0 --permanent
sudo firewall-cmd --reload