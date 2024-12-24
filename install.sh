#!\bin\bash

###Déclaration des couleurs
RED='\033[0;31m'
BLUE='\033[1;34m'
NC='\033[0m'

###Configuration de DNF
echo "fastestmirror=true" | sudo tee -a /etc/dnf/dnf.conf
echo "max_parallel_downloads=10" | sudo tee -a /etc/dnf/dnf.conf
echo "deltarpm=false" | sudo tee -a /etc/dnf/dnf.conf
sudo dnf install -y --nogpgcheck "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm"
sudo dnf install -y --nogpgcheck "https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"
sudo dnf install dnf-utils -y
sudo dnf install -y dnf-plugins-core
sudo ssh-keygen -t ed25519
sudo dnf install -y python3 python3-pip

#Mettre à jour le système
sudo dnf update -y && sudo dnf upgrade -y

#Installation des Drivers carte graphique
echo -e "${BLUE}Souhaitez-vous installer les pilotes graphiques ?${NC}"
echo "Appuyez sur 1 pour installer les pilotes graphiques."
echo "Appuyez sur 2 pour poursuivre la configuration sans installer les pilotes."
read -p "Entrez votre choix (1 ou 2) : " choix

if [ "$choix" -eq 1 ]; then
    # Appel du script script1.sh pour installer les pilotes graphiques dans le dossier CG-Drivers
    bash ./bash/CG-Drivers.sh
else
    echo "Poursuite de la configuration sans pilotes graphiques..."
fi
#Fin du script CG-Drivers

#Installation d'Ansible et lancement des playbooks
echo "Installation d'Ansible et lancement des playbooks"
sudo dnf install ansible ansible-core -y
ansible-playbook --become ./ansible/main.playbook.yml -c local
sudo flatpak update -y

###Configuration de la personnalisation de Gnome
bash ./bash/gnome-settings.sh

###Installation des extensions
bash ./bash/extensions.sh

###Installation de terraform
bash ./bash/terraform.sh

###Installation de virtualbox
bash ./bash/virtualbox.sh

#Redémarrage
sudo reboot now

