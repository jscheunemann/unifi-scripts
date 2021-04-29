#!/usr/bin/env bash

# Install necessary packages
sudo apt install -y git apt-rdepends

# Clone this repository
git clone https://github.com/jscheunemann/unifi-scripts.git unifi-scripts

# Mongo sources
wget -qO - https://www.mongodb.org/static/pgp/server-3.4.asc |  apt-key add -
echo "deb http://repo.mongodb.org/apt/debian jessie/mongodb-org/3.4 main" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.4.list

# Java 8
wget -qO - https://adoptopenjdk.jfrog.io/adoptopenjdk/api/gpg/key/public | sudo apt-key add -
sudo add-apt-repository --yes https://adoptopenjdk.jfrog.io/adoptopenjdk/deb/

# Unifi
apt-key adv --keyserver keyserver.ubuntu.com --recv 06E85760C0A52C50
echo 'deb https://www.ui.com/downloads/unifi/debian stable ubiquiti' | sudo tee /etc/apt/sources.list.d/100-ubnt-unifi.list

sudo apt update

gpg --gen-key
mkdir unifi_packages
cd unifi_packages
wget http://security.debian.org/debian-security/pool/updates/main/o/openssl/libssl1.0.0_1.0.1t-1+deb8u12_amd64.deb
~/unifi-scripts/get-deb-packages-with-deps.sh apt-transport-https
~/unifi-scripts/get-deb-packages-with-deps.sh ca-certificates
~/unifi-scripts/get-deb-packages-with-deps.sh wget
~/unifi-scripts/get-deb-packages-with-deps.sh software-properties-common
~/unifi-scripts/get-deb-packages-with-deps.sh multiarch-support
~/unifi-scripts/get-deb-packages-with-deps.sh gpgconf
~/unifi-scripts/get-deb-packages-with-deps.sh libassuan0
~/unifi-scripts/get-deb-packages-with-deps.sh gpg
~/unifi-scripts/get-deb-packages-with-deps.sh libnpth0
~/unifi-scripts/get-deb-packages-with-deps.sh libksba8
~/unifi-scripts/get-deb-packages-with-deps.sh dirmngr
~/unifi-scripts/get-deb-packages-with-deps.sh gnupg-l10n
~/unifi-scripts/get-deb-packages-with-deps.sh gnupg-utils
~/unifi-scripts/get-deb-packages-with-deps.sh pinentry-curses
~/unifi-scripts/get-deb-packages-with-deps.sh gpg-agent
~/unifi-scripts/get-deb-packages-with-deps.sh gpg-wks-client
~/unifi-scripts/get-deb-packages-with-deps.sh gpg-wks-server
~/unifi-scripts/get-deb-packages-with-deps.sh gpgsm
~/unifi-scripts/get-deb-packages-with-deps.sh gnupg
~/unifi-scripts/get-deb-packages-with-deps.sh gnupg2
~/unifi-scripts/get-deb-packages-with-deps.sh adoptopenjdk-8-hotspot
~/unifi-scripts/get-deb-packages-with-deps.sh unifi
~/unifi-scripts/get-deb-packages-with-deps.sh sudo
gpg --output public.key --armor --export jason.scheunemann@gmail.com
~/unifi-scripts/deb-repo.sh
cd
tar czvf unifi_packages.tgz unifi_packages
cat ~/unifi-scripts/create_unifi_installer.sh unifi_packages.tgz > unifi_installer.sh
