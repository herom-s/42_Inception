#!/bin/sh
set -e

# Read parameters directly from Docker secrets
SQL_DATABASE=$(cat /run/secrets/db_name)
SQL_USER=$(cat /run/secrets/db_user)
SQL_PASSWORD=$(cat /run/secrets/db_password)

WP_ADMIN_USER=$(cat /run/secrets/wp_admin_user)
WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
WP_USER=$(cat /run/secrets/wp_user)
WP_PASSWORD=$(cat /run/secrets/wp_password)

envsubst '$WP_PORT' < /etc/php82/php-fpm.d/www.conf.template > /etc/php82/php-fpm.d/www.conf

# Loop check: Wait cleanly until MariaDB server is active and accessible via port 3306
echo "Checking MariaDB communication channel..."
while ! nc -z mariadb ${DB_PORT}; do
    echo "Waiting for MariaDB network socket to open..."
    sleep 2
done
echo "MariaDB network channel established! Moving forward with installation..."

# If WordPress is not yet downloaded, pull core files and configure them
if [ ! -f "wp-config.php" ]; then
    echo "Downloading WordPress core engine files..."
    wp core download --allow-root

    echo "Configuring database connection parameters..."
    wp config create \
        --dbname="${SQL_DATABASE}" \
        --dbuser="${SQL_USER}" \
        --dbpass="${SQL_PASSWORD}" \
        --dbhost="mariadb:${DB_PORT}" \
        --allow-root

    echo "Executing standard WordPress core installation routine..."
    wp core install \
        --url="https://${DOMAIN_NAME}" \
        --title="Inception Site" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_USER}@42.fr" \
        --skip-email \
        --allow-root

    echo "Creating secondary user account credentials..."
    wp user create "${WP_USER}" "${WP_USER}@42.fr" \
        --user_pass="${WP_PASSWORD}" \
        --role=author \
        --allow-root

	echo "Installing and activating Redis object cache..."
	wp plugin install redis-cache --activate --allow-root
	wp config set WP_REDIS_HOST "${REDIS_HOST}" --allow-root
	wp config set WP_REDIS_PORT "${REDIS_PORT}" --allow-root
	wp config set WP_REDIS_CLIENT predis --allow-root
	wp redis enable --allow-root

	# Ensure correct runtime file system permissions
    chown -R nobody:nobody /var/www/html
fi

echo "WordPress service initialization completed successfully."
exec "$@"
