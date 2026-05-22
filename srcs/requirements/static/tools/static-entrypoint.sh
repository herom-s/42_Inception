#!/bin/sh
set -e

envsubst '${STATIC_PORT}' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

exec "$@"