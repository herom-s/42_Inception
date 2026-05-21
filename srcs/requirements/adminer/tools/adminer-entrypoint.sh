#!/bin/sh
set -e

/usr/sbin/php-fpm82 -D
exec nginx -g "daemon off;"
