#!/bin/sh
set -e

envsubst '${ADMINER_PORT}' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

/usr/sbin/php-fpm82 -D
exec nginx -g "daemon off;"
