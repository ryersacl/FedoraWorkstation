#!\bin\bash

###Déclaration des couleurs
RED='\033[0;31m'
BLUE='\033[1;34m'
NC='\033[0m'

###Installation de Virtualbox
#Message d'alerte
echo "Installation de virtualbox"
echo -e "${RED}ATTENTION${NC}"
echo -e "${RED}le système a besoin de redémarrer après pour configurer la clef MOK, il redémarrera à la fin de cette étape${NC}"
echo -e "${RED}Pensez donc à sauvegarder votre travail${NC}"
echo -e "${RED}De plus il faudra enroller la clef avec le mdp que vous allez configurer${NC}"
echo " "
echo " "
echo " "
echo -e "${RED}Veuillez appuyer sur une touche pour continuer${NC}"
read -p ""
#Augmenter la limite de mémoire verrouillé à 32go / Pour que les VM puissent utiliser plus que 8go de RAM
MEMLOCK_LIMIT=32768
# Ajoute les lignes à /etc/security/limits.conf
echo "* soft memlock $MEMLOCK_LIMIT" >> /etc/security/limits.conf
echo "* hard memlock $MEMLOCK_LIMIT" >> /etc/security/limits.conf
echo "Limite de mémoire verrouillée mise à jour à $MEMLOCK_LIMIT kB (32 Go)."
#Ajout du dépot
sudo dnf install -y @development-tools
sudo dnf install -y kernel-headers kernel-devel dkms
REPO_FILE="/etc/yum.repos.d/virtualbox.repo"
# Contenu du fichier de dépôt
cat <<EOF | sudo tee $REPO_FILE > /dev/null
[virtualbox]
name=Fedora \$releasever - \$basearch - VirtualBox
baseurl=http://download.virtualbox.org/virtualbox/rpm/fedora/\$releasever/\$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://www.virtualbox.org/download/oracle_vbox_2016.asc
EOF
#Mise à jour du cache yum pour prendre en compte le nouveau dépôt
sudo dnf -y makecache
sudo dnf update -y
#Installation du paquet
sudo dnf install -y VirtualBox-7.0
vboxmanage -v | cut -dr -f1
wget https://download.virtualbox.org/virtualbox/7.0.18/Oracle_VM_VirtualBox_Extension_Pack-7.0.18.vbox-extpack
sudo vboxmanage extpack install Oracle_VM_VirtualBox_Extension_Pack-7.0.18.vbox-extpack
sudo VBoxManage setextradata global GUI/SuppressMessages confirmGoingFullscreen,remindAboutMouseIntegration,remindAboutAutoCapture
sudo usermod -a -G vboxusers $USER
sudo /sbin/vboxconfig
sudo mkdir -p /var/lib/shim-signed/mok
sudo openssl req -nodes -new -x509 -newkey rsa:2048 -outform DER -addext "extendedKeyUsage=codeSigning" -keyout /var/lib/shim-signed/mok/MOK.priv -out /var/lib/shim-signed/mok/MOK.der
sudo mokutil --import /var/lib/shim-signed/mok/MOK.der
echo -e "${RED}Veuillez lancer la commande${NC} rcvboxdrv setup ${RED}après le redémarrage du système${NC}"
echo "______________________________________________________________________________ "
echo -e "${RED}VEUILLEZ APPUYER SUR UNE TOUCHE POUR REDÉMARRER${NC}"
read -p ""