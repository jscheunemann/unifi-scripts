#!/usr/bin/env bash

# cat create_unifi_installer.sh unifi_packages.tgz > unifi_installer.sh

set -e

# Ensure the script is ran as root
if [[ ${EUID} -ne 0 ]]; then
    echo "This script must be ran as root."
    exit 1
fi

mkdir -p /var/unifi_installer

BEGIN_ARCHIVE=`awk '/^__ARCHIVE_BELOW__/ {print NR + 1; exit 0; }' $0`

tail -n+$BEGIN_ARCHIVE $0 | tar xzv -C /var/unifi_installer

python3 -m http.server -d /var/unifi_installer/unifi_packages &

dpkg -i /var/unifi_installer/unifi_packages/libassuan0_2.5.2-1_amd64.deb
dpkg -i /var/unifi_installer/unifi_packages/gpgconf_2.2.12-1+deb10u1_amd64.deb
dpkg -i /var/unifi_installer/unifi_packages/gpg_2.2.12-1+deb10u1_amd64.deb
dpkg -i /var/unifi_installer/unifi_packages/libnpth0_1.6-1_amd64.deb
dpkg -i /var/unifi_installer/unifi_packages/libksba8_1.3.5-2_amd64.deb
dpkg -i /var/unifi_installer/unifi_packages/dirmngr_2.2.12-1+deb10u1_amd64.deb
dpkg -i /var/unifi_installer/unifi_packages/gnupg-l10n_2.2.12-1+deb10u1_all.deb
dpkg -i /var/unifi_installer/unifi_packages/gnupg-utils_2.2.12-1+deb10u1_amd64.deb
dpkg -i /var/unifi_installer/unifi_packages/pinentry-curses_1.1.0-2_amd64.deb
dpkg -i /var/unifi_installer/unifi_packages/gpg-agent_2.2.12-1+deb10u1_amd64.deb
dpkg -i /var/unifi_installer/unifi_packages/gpg-wks-client_2.2.12-1+deb10u1_amd64.deb
dpkg -i /var/unifi_installer/unifi_packages/gpg-wks-server_2.2.12-1+deb10u1_amd64.deb
dpkg -i /var/unifi_installer/unifi_packages/gpgsm_2.2.12-1+deb10u1_amd64.deb
dpkg -i /var/unifi_installer/unifi_packages/gnupg_2.2.12-1+deb10u1_all.deb
dpkg -i /var/unifi_installer/unifi_packages/gnupg2_2.2.12-1+deb10u1_all.deb


: > /etc/apt/sources.list
echo "deb http://127.0.0.1:8000 /" | tee -a /etc/apt/sources.list

apt-key add /var/unifi_installer/unifi_packages/public.key
echo "JAVA_HOME=/usr/lib/jvm/adoptopenjdk-8-hotspot-amd64"

apt update -y
apt install -y adoptopenjdk-8-hotspot sudo
apt install -y unifi

usermod -aG sudo jason

: > /etc/apt/sources.list

REPO_URL=deb_repo.home.dev
echo "deb http://${REPO_URL}/debian/ buster main" | tee -a /etc/apt/sources.list
echo "deb http://${REPO_URL}/debian/security buster/updates main" | tee -a /etc/apt/sources.list
echo "deb http://${REPO_URL}/debian/ buster-updates main" | tee -a /etc/apt/sources.list

exit 0

__ARCHIVE_BELOW__
