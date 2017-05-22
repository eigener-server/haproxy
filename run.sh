#!/bin/bash
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
        touch /host/haproxy/firstrun

        #HA Proxy config
        cp /tmp/haproxy.cfg /host/haproxy/config/

        #HA Proxy Cert
        #make-ssl-cert generate-default-snakeoil
        cat /etc/ssl/private/ssl-cert-snakeoil.key /etc/ssl/certs/ssl-cert-snakeoil.pem > /host/haproxy/certs/selfsigned.pem

        #nextcloud container running
        if `getent hosts nextcloud`; then
                sed -i 's/#server web01 nextcloud/server web01 nextcloud/g' /host/haproxy/config/haproxy.cfg
        fi
        #letsencrypt container running?
        if `getent hosts letsencrypt`; then
                sed -i 's/#server web01 letsencrypt/server web01 letsencrypt/g' /host/haproxy/config/haproxy.cfg
        fi
fi


# This runs after every boot
if [ ! -f /firstrun ]; then

        echo "container booted"
        touch /firstrun

fi

exec "$@"
