#!/bin/bash

###Déclaration des couleurs
RED='\033[0;31m'
BLUE='\033[1;34m'
NC='\033[0m'

#Installation des extensions
echo "Installation des extensions / ATTENTION Redémarrage imminent"
mkdir ~/.local/share/gnome-shell/extensions/
cp -r -f extensions/* ~/.local/share/gnome-shell/extensions/

