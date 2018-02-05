#!/bin/sh
set -e

PREFIX=/usr/local/etc/unbound
ROOT_HINTS_URL=https://www.internic.net/domain/named.cache

# Use fresh root hints file
curl -o ${PREFIX}/root.hints -sfSL ${ROOT_HINTS_URL}
echo 'Root hints have been successfully updated'

# Auto adjust the number of threads
if [ $(grep -c '{{THREADS}}' ${PREFIX}/unbound.conf) == 1 ]; then
    NPROC=$(nproc)
    [[ ${NPROC} -gt 1 ]] && THREADS=${NPROC} || THREADS=1
    sed -e "s/{{THREADS}}/${THREADS}/" -i ${PREFIX}/unbound.conf
fi

# Enable remote control
if [ ! -f ${PREFIX}/unbound_control.pem ]; then
    unbound-control-setup
fi

# Enable DNSSEC
if [ ! -f ${PREFIX}/var/root.key ]; then
    mkdir -p -m 700 ${PREFIX}/var
    chown unbound:unbound ${PREFIX}/var
    unbound-anchor -a ${PREFIX}/var/root.key -r ${PREFIX}/root.hints
fi

unbound-checkconf
exec $@
