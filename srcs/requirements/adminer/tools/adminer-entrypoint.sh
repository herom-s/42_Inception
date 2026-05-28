#!/bin/sh
set -e

envsubst '${ADMINER_PORT},${WP_PORT}' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

exec "$@"