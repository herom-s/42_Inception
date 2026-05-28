#!/bin/sh
set -e

envsubst '${ADMINER_PORT},${WP_PORT}' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

mkdir -p /var/www/html/adminer
cp /var/www/adminer/index.php /var/www/html/adminer/index.php

exec "$@"
