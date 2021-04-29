#!/bin/bash

function die() {
    declare -i EXIT_CODE
    EXIT_CODE=${1}

    [ "${EXIT_CODE}" == "" ] && exit 0 || exit "${EXIT_CODE}"
}

DPKG_DEV_INSTALLED=$(command -v dpkg-architecture | wc -l)

if [ ! "${DPKG_DEV_INSTALLED}" -eq 1 ]; then
    echo "ERROR: Could not find dpkg-architecture. Install the dpkg-dev package (apt install dpkg-dev)"
    die 1
fi

dpkg-scanpackages . /dev/null > Packages
gzip --keep --force -9 Packages

FILE=Release

OS_RELEASE_FILE=/etc/os-release

function title_case() {
    local VAR=${1}
    echo $(tr '[:lower:]' '[:upper:]' <<< ${VAR:0:1})${VAR:1}
}
function get_value_from_key_val_pair_file() {
    echo $(sed -n "s/^${2}[[:blank:]]*=[[:blank:]]*\(.*\)/\1/p" ${1} | tr ' ' '-' | tr -d '"')
}

function get_linux_distro() {
    echo $(get_value_from_key_val_pair_file "${OS_RELEASE_FILE}" "ID")
}

DISTRO_RAW=$(get_linux_distro)
DISTRO=$(title_case ${DISTRO_RAW})

FILE=Release

cat > $FILE <<- EOF
Archive: stable
Origin: ${DISTRO}
Label: ${DISTRO}
Version: $(cat /etc/debian_version)
Acquire-By-Hash: yes
Component: main
Architecture: $(dpkg-architecture -q DEB_BUILD_ARCH)
EOF

# The Date: field has the same format as the Debian package changelog entries,
# that is, RFC 2822 with time zone +0000
echo -e "Date: `LANG=C date -Ru`" >> Release

# Release must contain MD5 sums of all repository files (in a simple repo just the Packages and Packages.gz files)
echo -e 'MD5Sum:' >> Release
printf ' '$(md5sum Packages.gz | cut --delimiter=' ' --fields=1)' %16d Packages.gz' $(wc --bytes Packages.gz | cut --delimiter=' ' --fields=1) >> Release
printf '\n '$(md5sum Packages | cut --delimiter=' ' --fields=1)' %16d Packages' $(wc --bytes Packages | cut --delimiter=' ' --fields=1) >> Release

# Release must contain SHA256 sums of all repository files (in a simple repo just the Packages and Packages.gz files)
echo -e '\nSHA256:' >> Release
printf ' '$(sha256sum Packages.gz | cut --delimiter=' ' --fields=1)' %16d Packages.gz' $(wc --bytes Packages.gz | cut --delimiter=' ' --fields=1) >> Release
printf '\n '$(sha256sum Packages | cut --delimiter=' ' --fields=1)' %16d Packages' $(wc --bytes Packages | cut --delimiter=' ' --fields=1) >> Release

# Clearsign the Release file (that is, sign it without encrypting it)
gpg --clearsign --digest-algo SHA512 --local-user $USER -o InRelease Release
