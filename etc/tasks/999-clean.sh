#!/bin/bash
if [[ ! -f /.dockerenv ]]; then
    echo "This script cannot be executed outside of a docker container."
    exit 1
fi

sudo yum clean all

sudo rm -rf "${HOME}/.astropy"
sudo rm -rf "${HOME}"/*
sudo rm -rf /tmp/*
sudo rm -rf /var/cache/yum

for logfile in /var/log/*
do
    [[ -f ${logfile} ]] && sudo truncate --size=0 "${logfile}"
done
