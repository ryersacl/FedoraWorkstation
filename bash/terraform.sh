#!\bin\bash

###Déclaration des couleurs
RED='\033[0;31m'
BLUE='\033[1;34m'
NC='\033[0m'

#Installer Terraform
sudo tee /etc/yum.repos.d/hashicorp.repo > /dev/null <<EOF
[hashicorp]
name=HashiCorp Stable - \$basearch
baseurl=https://rpm.releases.hashicorp.com/RHEL/9/\$basearch/stable
enabled=1
gpgcheck=1
gpgkey=https://rpm.releases.hashicorp.com/gpg
EOF
sudo dnf -y install terraform
