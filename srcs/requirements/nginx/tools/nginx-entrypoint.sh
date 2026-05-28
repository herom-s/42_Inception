#!/bin/sh
set -e

envsubst '${DOMAIN_NAME} ${WP_PORT} ${ADMINER_PORT} ${STATIC_PORT} ${PORTAINER_PORT}' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

if [ ! -f /etc/nginx/ssl/nginx-selfsigned.crt ]; then
    envsubst '${DOMAIN_NAME}' < /etc/nginx/ssl/openssl.conf.template > /etc/nginx/ssl/openssl.conf
    openssl req -config /etc/nginx/ssl/openssl.conf -new -x509 -sha256 -newkey rsa:2048 -nodes -batch \
        -keyout /etc/nginx/ssl/nginx-selfsigned.key -days 365 -out /etc/nginx/ssl/nginx-selfsigned.crt
fi

exec "$@"
