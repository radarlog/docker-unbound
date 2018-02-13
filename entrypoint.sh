#!/bin/sh
set -e

PREFIX=/usr/local/etc/unbound
KEYS_DIR=${PREFIX}/keys
ROOT_HINTS_URL=https://www.internic.net/domain/named.cache
ROOT_HINTS_FILE=${KEYS_DIR}/unbound_root.hints
ANCHOR_FILE=${KEYS_DIR}/unbound_anchor.key

# Auto adjust the number of threads
if [ $(grep -c '{{THREADS}}' ${PREFIX}/unbound.conf) == 1 ]; then
    NPROC=$(nproc)
    [[ ${NPROC} -gt 1 ]] && THREADS=${NPROC} || THREADS=1
    sed -e "s/{{THREADS}}/${THREADS}/" -i ${PREFIX}/unbound.conf
fi

# Enable remote control
if [ ! -f ${KEYS_DIR}/unbound_control.pem ]; then
    unbound-control-setup -d ${KEYS_DIR}
fi

# Use fresh root hints file
curl -o ${ROOT_HINTS_FILE} -sfSL ${ROOT_HINTS_URL}
echo 'Root hints have been successfully updated'

# Enable DNSSEC
if [ ! -f ${ANCHOR_FILE} ]; then
    unbound-anchor -a ${ANCHOR_FILE} -r ${ROOT_HINTS_FILE}
fi

unbound-checkconf
exec $@
