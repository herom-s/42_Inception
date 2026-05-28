#!/bin/sh
set -e

PORTAINER_USER=$(cat /run/secrets/portainer_user)
PORTAINER_PASSWORD=$(cat /run/secrets/portainer_password)

/usr/local/bin/portainer --no-analytics -H unix:///var/run/docker.sock &
PORTAINER_PID=$!

echo "Waiting for Portainer to start..."
until wget -qO- http://localhost:${PORTAINER_PORT}/api/status > /dev/null 2>&1; do
    sleep 1
done

wget -qO- \
    --post-data "{\"Username\":\"${PORTAINER_USER}\",\"Password\":\"${PORTAINER_PASSWORD}\"}" \
    --header "Content-Type: application/json" \
    http://localhost:${PORTAINER_PORT}/api/users/admin/init > /dev/null 2>&1 && \
    echo "Portainer admin password set." || \
    echo "Portainer admin already initialized, skipping."

wait $PORTAINER_PID
