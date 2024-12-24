#!\bin\bash

###Déclaration des couleurs
RED='\033[0;31m'
BLUE='\033[1;34m'
NC='\033[0m'

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
sudo cp ../wallpaper/wallpaper.jpg /usr/share/backgrounds/fedora-workstation/
gsettings set org.gnome.desktop.background picture-uri-dark /usr/share/backgrounds/fedora-workstation/wallpaper.jpg
gsettings set org.gnome.desktop.background picture-uri /usr/share/backgrounds/fedora-workstation/wallpaper.jpg

#Paramètres de confidentialités
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

#Paramètres de Gnome
echo "Configuration de GNOME Logiciels"
echo " - Désactivation du téléchargement automatique des mises à jour"
gsettings set org.gnome.software download-updates false
echo " - Activation de l'affichage des logiciels propriétaires"
gsettings set org.gnome.software show-only-free-apps false


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
