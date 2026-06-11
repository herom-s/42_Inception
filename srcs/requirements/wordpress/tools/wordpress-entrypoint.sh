#!/bin/sh
set -e

SQL_DATABASE=$(cat /run/secrets/db_name)
SQL_USER=$(cat /run/secrets/db_user)
SQL_PASSWORD=$(cat /run/secrets/db_password)
WP_ADMIN_USER=$(cat /run/secrets/wp_admin_user)
WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
WP_USER=$(cat /run/secrets/wp_user)
WP_PASSWORD=$(cat /run/secrets/wp_password)

envsubst '$WP_PORT' < /etc/php82/php-fpm.d/www.conf.template > /etc/php82/php-fpm.d/www.conf

echo "Checking MariaDB communication channel..."
while ! nc -z mariadb ${DB_PORT}; do
    echo "Waiting for MariaDB network socket to open..."
    sleep 2
done
echo "MariaDB network channel established! Moving forward..."

CONFIG_HASH=$(printf '%s' \
    "$SQL_DATABASE" "$SQL_USER" "$SQL_PASSWORD" \
    "$WP_ADMIN_USER" "$WP_ADMIN_PASSWORD" \
    "$WP_USER" "$WP_PASSWORD" \
    "$DB_PORT" "$DOMAIN_NAME" \
    "$REDIS_HOST" "$REDIS_PORT" \
    | sha256sum | cut -d' ' -f1)

HASH_FILE="/var/www/html/.config_hash"

apply_wp_config() {
    echo "Applying wp-config settings..."
    wp config set DB_NAME     "$SQL_DATABASE"       --allow-root
    wp config set DB_USER     "$SQL_USER"            --allow-root
    wp config set DB_PASSWORD "$SQL_PASSWORD"        --allow-root
    wp config set DB_HOST     "mariadb:${DB_PORT}"   --allow-root
    wp config set WP_REDIS_HOST   "$REDIS_HOST"      --allow-root
    wp config set WP_REDIS_PORT   "$REDIS_PORT"      --allow-root
    wp config set WP_REDIS_CLIENT predis             --allow-root
    wp redis enable --allow-root
}

if [ ! -f "/var/www/html/wp-config.php" ]; then
    echo "Downloading WordPress core engine files..."
    wp core download --allow-root

    echo "Configuring database connection parameters..."
    wp config create \
        --dbname="${SQL_DATABASE}" \
        --dbuser="${SQL_USER}" \
        --dbpass="${SQL_PASSWORD}" \
        --dbhost="mariadb:${DB_PORT}" \
        --allow-root

    echo "Executing WordPress core installation..."
    wp core install \
        --url="https://${DOMAIN_NAME}" \
        --title="Inception Site" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_USER}@42.fr" \
        --skip-email \
        --allow-root

    echo "Creating secondary user account..."
    wp user create "${WP_USER}" "${WP_USER}@42.fr" \
        --user_pass="${WP_PASSWORD}" \
        --role=author \
        --allow-root

    echo "Installing and activating Redis object cache..."
    wp plugin install redis-cache --activate --allow-root

    apply_wp_config

    chown -R nobody:nobody /var/www/html
    echo "$CONFIG_HASH" > "$HASH_FILE"

else
    STORED_HASH=""
    [ -f "$HASH_FILE" ] && STORED_HASH=$(cat "$HASH_FILE")

    if [ "$CONFIG_HASH" != "$STORED_HASH" ]; then
        echo "Config change detected — re-applying all settings..."
        apply_wp_config
        echo "$CONFIG_HASH" > "$HASH_FILE"
    else
        echo "Config unchanged, skipping reconfiguration."
    fi

    chown -R nobody:nobody /var/www/html
    mkdir -p /var/www/html/wp-content/uploads
    chmod -R 775 /var/www/html/wp-content/uploads
fi

echo "WordPress service initialization completed successfully."
exec "$@"
