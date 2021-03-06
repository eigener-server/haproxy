#!/bin/bash

# Hedgehog Cloud by www.eigener-server.ch https://www.eigener-server.ch/en/igel-cloud \
# is licensed under a Creative Commons Attribution 4.0 International Lizenz \
# http://creativecommons.org/licenses/by/4.0/ \
# To remove the links visit https://www.eigener-server.ch/en/igel-cloud"

set -e

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- haproxy "$@"
fi

if [ "$1" = 'haproxy' ]; then
	# if the user wants "haproxy", let's use "haproxy-systemd-wrapper" instead so we can have proper reloadability implemented by upstream
	shift # "haproxy"
	set -- "$(which haproxy-systemd-wrapper)" -p /run/haproxy.pid "$@"
fi

# This runs after first start (Folder should be a folder on host)
if [ ! -f /host/haproxy/firstrun ]; then

        echo "container first run"
        mkdir -p /host/haproxy/config
        mkdir -p /host/haproxy/certs

        #HA Proxy config
        cp /tmp/haproxy.cfg /host/haproxy/config/

        #HA Proxy Cert
        #make-ssl-cert generate-default-snakeoil
        cat /etc/ssl/private/ssl-cert-snakeoil.key /etc/ssl/certs/ssl-cert-snakeoil.pem > /host/haproxy/certs/selfsigned.pem

        sed -i -e "s/user admin insecure-password.*/user ${HAPROXY_ADMIN_USER} insecure-password ${HAPROXY_ADMIN_PASSWORD}/" /host/haproxy/config/haproxy.cfg
        sed -i -e "s#acl admin_white_list src.*#acl admin_white_list src ${HAPROXY_ADMIN_USER_IP}#g" /host/haproxy/config/haproxy.cfg


        touch /host/haproxy/firstrun
fi


# This runs after every boot
if [ ! -f /firstrun ]; then

        echo "container booted"
        touch /firstrun

fi

exec "$@"
