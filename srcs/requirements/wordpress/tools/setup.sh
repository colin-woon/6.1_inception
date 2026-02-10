#!/bin/bash
set -e

# Helper: Reads the secret from the file if it exists, otherwise uses the raw value.
# Usage: MYSQL_USER=$(get_secret "$MYSQL_USER_FILE" "$MYSQL_USER")
get_secret() {
    if [ -r "$1" ]; then
        cat "$1" | tr -d '\n'
    else
        echo "$2"
    fi
}

check_secret() {
    if [ -z "$1" ]; then
        echo "ERROR: $2 is not set!" >&2
        exit 1
    fi
}

# Load secrets into local variables (not exported to env)
MYSQL_USER=$(get_secret "$MYSQL_USER_FILE" "$MYSQL_USER")
MYSQL_PASSWORD=$(get_secret "$MYSQL_PASSWORD_FILE" "$MYSQL_PASSWORD")
MYSQL_ROOT_PASSWORD=$(get_secret "$MYSQL_ROOT_PASSWORD_FILE" "$MYSQL_ROOT_PASSWORD")
WP_USER=$(get_secret "$WP_USER_FILE" "$WP_USER")
WP_USER_PASSWORD=$(get_secret "$WP_USER_PASSWORD_FILE" "$WP_USER_PASSWORD")
WP_ADMIN=$(get_secret "$WP_ADMIN_FILE" "$WP_ADMIN")
WP_ADMIN_PASSWORD=$(get_secret "$WP_ADMIN_PASSWORD_FILE" "$WP_ADMIN_PASSWORD")

check_secret "$MYSQL_USER" "MYSQL_USER"
check_secret "$MYSQL_PASSWORD" "MYSQL_PASSWORD"
check_secret "$MYSQL_ROOT_PASSWORD" "MYSQL_ROOT_PASSWORD"
check_secret "$WP_USER" "WP_USER"
check_secret "$WP_USER_PASSWORD" "WP_USER_PASSWORD"
check_secret "$WP_ADMIN" "WP_ADMIN"
check_secret "$WP_ADMIN_PASSWORD" "WP_ADMIN_PASSWORD"

# 1. Wait for MariaDB to actually be ready
# We use mariadb-client to ping the host until it answers
echo "Waiting for MariaDB..."
until mariadb-admin ping -h"mariadb" -u root -p${MYSQL_ROOT_PASSWORD} --silent; do
    echo "MariaDB is still sleeping... retrying"
    sleep 1
done
echo "MariaDB is online."

# 2. Check if WordPress is already installed
if [ -f ./wp-config.php ]; then
    echo "WordPress already installed."
else
    echo "Installing WordPress..."

    # Download
    wp core download --allow-root

    # Config
    wp config create --allow-root \
        --dbname="$MYSQL_DATABASE" \
        --dbuser="$MYSQL_USER" \
        --dbpass="$MYSQL_PASSWORD" \
        --dbhost=mariadb:3306 \
        --path="/var/www/html"

    # Install
    wp core install --allow-root \
        --url="$DOMAIN_NAME" \
        --title="$SITE_TITLE" \
        --admin_user="$WP_ADMIN" \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --path="/var/www/html"

    wp user create --allow-root \
        "$WP_USER" "$WP_USER_EMAIL" \
        --user_pass="$WP_USER_PASSWORD" \
        --role=author \
        --path="/var/www/html"
    echo "WordPress installed successfully."

    # 1. Install and activate the Redis Cache plugin
    wp plugin install redis-cache --activate --allow-root --path='/var/www/html'

    # 2. Add Redis config to wp-config.php
    # We point it to our container name 'redis' on port 6379
    wp config set WP_REDIS_HOST redis --allow-root --path='/var/www/html'
    wp config set WP_REDIS_PORT 6379 --raw --allow-root --path='/var/www/html'
    # wp config set WP_REDIS_CLIENT predis --allow-root --path='/var/www/html'

    # 3. Enable the object cache
    wp redis enable --allow-root --path='/var/www/html'

fi
# Important if host port is not 443, and you want to use different port, can uncomment and try to bind a different port, you will see 502
echo "Configuring WordPress to handle ports correctly..."
# wp config set WP_HOME "'https://' . \$_SERVER['HTTP_HOST']" --raw --allow-root --path="/var/www/html"
# wp config set WP_SITEURL "'https://' . \$_SERVER['HTTP_HOST']" --raw --allow-root --path="/var/www/html"

# Ensure the Specialist (www-data) owns the Body before starting
chown -R www-data:www-data /var/www/html

# 3. Start PHP-FPM as foreground (-F)
echo "Starting PHP-FPM ${PHP_VERSION}"
exec php-fpm${PHP_VERSION} -F
