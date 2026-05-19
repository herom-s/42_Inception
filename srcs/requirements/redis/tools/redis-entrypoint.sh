#!/bin/sh
set -e

envsubst '$REDIS_PORT' < /etc/redis/redis.conf.template > /etc/redis/redis.conf

exec "$@"
