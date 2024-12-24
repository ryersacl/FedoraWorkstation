#!/bin/bash

###Déclaration des couleurs
RED='\033[0;31m'
BLUE='\033[1;34m'
NC='\033[0m' 

# Fonction pour installer les drivers AMD
install_amd() {
    echo "Installation des pilotes AMD..."
    sudo dnf install mesa-libOpenCL mesa-libd3d mesa-va-drivers mesa-vdpau-drivers -y
    sudo dnf install mesa-libOpenCL libclc clinfo -y
    sudo dnf install -y hip hip-devel hsakmt rocm-clinfo rocm-cmake rocm-comgr rocm-device-libs rocm-hip rocm-hip-devel rocm-opencl rocm-opencl-devel rocm-runtime rocm-smi rocminfo hipblas hipblas-devel rocblas rocsolver rocsparse
    sudo dnf install -y amd-gpu-firmware xorg-x11-drv-amdgpu
    sudo usermod -aG video $USER 
    echo "Pilotes AMD installés avec succès."
}

# Fonction pour installer les drivers NVIDIA
install_nvidia() {
    echo "Installation des pilotes NVIDIA..."
    sudo dnf install -y kernel-devel kernel-headers gcc make dkms acpid libglvnd-glx libglvnd-opengl libglvnd-devel pkgconfig
    sudo dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda
    sudo dnf install -y nvidia-vaapi-driver libva-utils vdpauinfo
    sudo usermod -aG video $USER 
    echo "Pilotes NVIDIA installés avec succès."
}

# Menu de sélection
echo -e "${BLUE}Veuillez sélectionner votre carte graphique:${NC}"
echo "1 - Vous avez une carte graphique AMD"
echo "2 - Vous avez une carte graphique NVIDIA"
read -p "Entrez votre choix (1 ou 2) : " choix

case $choix in
    1)
        install_amd
        ;;
    2)
        install_nvidia
        ;;
    *)
        echo "Choix invalide, veuillez entrer 1 ou 2."
        ;;
esac