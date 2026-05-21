#!/bin/sh
set -e

envsubst '${DOMAIN_NAME} ${WP_PORT}' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

exec "$@"
