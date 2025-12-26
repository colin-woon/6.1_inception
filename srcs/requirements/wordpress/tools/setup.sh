#!/bin/bash

# 1. Wait for MariaDB to actually be ready
# We use mariadb-client to ping the host until it answers
echo "Waiting for MariaDB..."
until mariadb-admin ping -h"mariadb-test" -u root -p${MYSQL_ROOT_PASSWORD} --silent; do
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
        --dbhost=mariadb-test:3306 \
		--path="/var/www/html"

    # Install
    wp core install --allow-root \
        --url="$DOMAIN_NAME" \
        --title="$SITE_TITLE" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="$WP_ADMIN_EMAIL" \
		--path="/var/www/html"

	wp user create --allow-root \
        "$WP_USER" "$WP_USER_EMAIL" \
        --user_pass="$WP_USER_PASSWORD" \
        --role=author \
        --path="/var/www/html"
    echo "WordPress installed successfully."
fi

# Ensure the Specialist (www-data) owns the Body before starting
chown -R www-data:www-data /var/www/html

# 3. Start PHP-FPM
echo "Starting PHP-FPM"
exec php-fpm${$PHP_VERSION} -F
