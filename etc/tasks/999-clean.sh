#!/bin/bash
if [[ ! -f /.dockerenv ]]; then
    echo "This script cannot be executed outside of a docker container."
    exit 1
fi

packages=(
    gcc
    gcc-c++
    gcc-gfortran
)
sudo yum remove -y "${packages[@]}"
sudo yum clean all

# Remove all static libraries
sudo find "${TOOLCHAIN_LIB}" -name '*.a' -delete

sudo rm -rf "${HOME}/.astropy"
sudo rm -rf "${HOME}"/*
sudo rm -rf /tmp/*
sudo rm -rf /var/cache/yum

for logfile in /var/log/*
do
    [[ -f ${logfile} ]] && sudo truncate --size=0 "${logfile}"
done
