#!/bin/sh
set -e

# Read credentials from Docker secrets (same pattern as wordpress-entrypoint.sh)
SQL_DATABASE=$(cat /run/secrets/db_name)
SQL_USER=$(cat /run/secrets/db_user)
SQL_PASSWORD=$(cat /run/secrets/db_password)
SQL_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

envsubst '$DB_PORT' < /etc/mariadb-server.cnf.template > /etc/my.cnf.d/mariadb-server.cnf

DATA_DIR="/var/lib/mysql"

if [ ! -d "$DATA_DIR/mysql" ]; then
    echo "Initializing MariaDB minimal data directory..."
    mariadb-install-db --user=mysql --datadir="$DATA_DIR"

    echo "Creating secure initialization temporary script..."
    cat << EOF > /tmp/init.sql
FLUSH PRIVILEGES;

-- Root: set password on the pre-existing localhost account (created by mariadb-install-db)
ALTER USER 'root'@'localhost' IDENTIFIED BY '${SQL_ROOT_PASSWORD}';

-- Root: create additional host entries for network access
CREATE USER IF NOT EXISTS 'root'@'127.0.0.1' IDENTIFIED BY '${SQL_ROOT_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'127.0.0.1' WITH GRANT OPTION;

CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '${SQL_ROOT_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;

-- WordPress database and application user
CREATE DATABASE IF NOT EXISTS \`${SQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${SQL_USER}'@'%' IDENTIFIED BY '${SQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${SQL_DATABASE}\`.* TO '${SQL_USER}'@'%';

FLUSH PRIVILEGES;
EOF

    echo "Executing bootstrap configuration..."
    mariadbd --user=mysql --datadir="$DATA_DIR" --bootstrap < /tmp/init.sql

    rm -f /tmp/init.sql
    echo "MariaDB configuration bootstrap completed successfully."
else
    echo "MariaDB storage directory already initialized. Skipping bootstrap."
fi

echo "Starting MariaDB engine..."
exec mariadbd --user=mysql --datadir="$DATA_DIR" --console
