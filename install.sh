#!\bin\bash

###Configuration de DNF
echo "fastestmirror=true" | sudo tee -a /etc/dnf/dnf.conf
echo "max_parallel_downloads=10" | sudo tee -a /etc/dnf/dnf.conf
echo "deltarpm=false" | sudo tee -a /etc/dnf/dnf.conf

#Installation des RPM Fusion Free
sudo dnf install -y --nogpgcheck "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm"
sudo dnf install -y --nogpgcheck "https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"

#Mettre à jour le système
sudo dnf update -y && sudo dnf upgrade -y

#Installation des Drivers AMD Radeon pour la CG 7800XT
sudo dnf install mesa-libOpenCL mesa-libd3d mesa-va-drivers mesa-vdpau-drivers -y
sudo dnf install mesa-libOpenCL libclc clinfo -y
sudo dnf install hip hip-devel hsakmt rocm-clinfo rocm-cmake rocm-comgr rocm-device-libs rocm-hip rocm-hip-devel rocm-opencl rocm-opencl-devel rocm-runtime rocm-smi rocminfo hipblas hipblas-devel rocblas rocsolver rocsparse -y
sudo usermod -aG video $USER 

#Install locate et dconf editor
sudo dnf install -y plocate
sudo updatedb
sudo dnf install -y dconf-editor

#Installer Gnome-tweaks et gestionnaire d'extensions
sudo dnf install gnome-extensions-app -y
flatpak install flathub org.gnome.Extensions -y
flatpak install flathub com.mattjakeman.ExtensionManager -y
sudo dnf install gnome-tweaks -y


#PARAMETRE SYSTEME >
#Activer le mode d'énergie sur Performance
echo "Paramètre d'Apparence"
echo " - Activer le mode d'énergie sur Performance"
sudo powerprofilesctl set performance
echo " - Désactiver le coin Actif"
gsettings set org.gnome.desktop.interface enable-hot-corners false
echo " - Activer le thème sombre pour interface GTK (fenetre, boutons,etc)"
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
echo " - Activer le thème sombre pour le shell GNOME"
gsettings set org.gnome.shell.extensions.user-theme name 'Adwaita-dark'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
sudo dnf install gnome-shell-extension-user-theme
gnome-extensions install user-theme@gnome-shell-extensions.gcampax.github.com
gnome-extensions list
gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com
echo " - Configuration du fond d'écran"
sudo cp wallpaper/wallpaper.jpg /usr/share/backgrounds/fedora-workstation/
gsettings set org.gnome.desktop.background picture-uri-dark /usr/share/backgrounds/fedora-workstation/wallpaper.jpg
gsettings set org.gnome.desktop.background picture-uri /usr/share/backgrounds/fedora-workstation/wallpaper.jpg


#Paramètres de confidentialité
echo "Confidentialité de GNOME"
echo " - Désactivation de l'envoi des rapports"
gsettings set org.gnome.desktop.privacy report-technical-problems false
echo " - Désactivation des statistiques des logiciels"
gsettings set org.gnome.desktop.privacy send-software-usage-stats false

#Paramètre de Nautilus
echo "Configuration Nautilus"
echo " - Désactivation de l ouverture du dossier lorsqu un élément est glissé dedans"
gsettings set org.gnome.nautilus.preferences open-folder-on-dnd-hover false
echo " - Activation du double clic"
gsettings set org.gnome.nautilus.preferences click-policy 'double'
echo " - Modification de l ordre de tri"
gsettings set org.gtk.Settings.FileChooser sort-directories-first true
gsettings set org.gtk.gtk4.Settings.FileChooser sort-directories-first true

echo "Configuration de GNOME Logiciels"
echo " - Désactivation du téléchargement automatique des mises à jour"
gsettings set org.gnome.software download-updates false
echo " - Activation de l'affichage des logiciels propriétaires"
gsettings set org.gnome.software show-only-free-apps false

#Installation d'Ansible et lancement des playbooks
echo "Installation d'Ansible et lancement des playbooks"
sudo ssh-keygen
sudo dnf install ansible -y
echo "[Fedora]" | sudo tee -a /etc/ansible/hosts
echo "127.0.0.1" | sudo tee -a /etc/ansible/hosts
ansible-playbook ansible-playbook/install_packet.yml -c local --ask-become-pass
ansible-playbook ansible-playbook/install_flatpak_software.yml -c local --ask-become-pass
ansible-playbook ansible-playbook/tweaks.yml -c local --ask-become-pass
sudo flatpak update -y

#Installation des extensions
echo "Installation des extensions / ATTENTION Redémarrage imminent"
mkdir ~/.local/share/gnome-shell/extensions/
cp -r -f extensions/* ~/.local/share/gnome-shell/extensions/

#Configurer les raccourcis
echo "Configuration des raccourcis"
echo " - Appuyer sur '<Super>c' pour lancer la calculatrice"
echo " - Appuyer sur '<Super>t' pour lancer le terminal"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ name 'Ouvrir Terminal'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ command 'gnome-terminal'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ binding '<Super>t'
echo " - Super + e : Ouvrir l'explorateur de fichiers dans le répertoire home"
gsettings set org.gnome.settings-daemon.plugins.media-keys home "['<Super>e']"
echo " - Super + m : Lancer le client de messagerie (par défaut Thunderbird)"
gsettings set org.gnome.settings-daemon.plugins.media-keys email "['<Super>m']"
echo " - Super + f : Lancer le navigateur web (par défaut Firefox)"
gsettings set org.gnome.settings-daemon.plugins.media-keys www "['<Super>f']"
echo " - Super + p : Ouvrir les paramètres"
gsettings set org.gnome.settings-daemon.plugins.media-keys control-center "['<Super>p']"
echo " - Super + r : Rechercher (Ouvre la recherche GNOME par défaut)"
gsettings set org.gnome.settings-daemon.plugins.media-keys search "['<Super>r']"
echo " - Super + c : Ouvrir la calculatrice"
gsettings set org.gnome.settings-daemon.plugins.media-keys calculator "['<Super>c']"

###Installation de Virtualbox
#Coloriser le script
RED='\033[0;31m'
NC='\033[0m' # No Color
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
sudo usermod -a -G vboxusers $USER
sudo /sbin/vboxconfig
sudo mkdir -p /var/lib/shim-signed/mok
sudo openssl req -nodes -new -x509 -newkey rsa:2048 -outform DER -addext "extendedKeyUsage=codeSigning" -keyout /var/lib/shim-signed/mok/MOK.priv -out /var/lib/shim-signed/mok/MOK.der
sudo mokutil --import /var/lib/shim-signed/mok/MOK.der
echo -e "${RED}Veuillez lancer la commande${NC} rcvboxdrv setup ${RED}après le redémarrage du système${NC}"
echo "______________________________________________________________________________ "
echo -e "${RED}VEUILLEZ APPUYER SUR UNE TOUCHE POUR REDÉMARRER${NC}"
read -p ""



#Redémarrage
sudo reboot now

