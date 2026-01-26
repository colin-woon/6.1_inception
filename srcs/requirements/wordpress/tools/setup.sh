#!/bin/bash
set -e

# --- 1. SECRET LOADING HELPER ---
# This function reads the file path provided by your _FILE variables
get_secret() {
    local var_name=$1
    local file_path="${!var_name}"

    if [ -f "$file_path" ]; then
        cat "$file_path"
    else
        # If the file doesn't exist, we look for the variable without _FILE
        # For example: if MYSQL_PASSWORD_FILE fails, look for MYSQL_PASSWORD
        local fallback_var="${var_name%_FILE}"
        echo "${!fallback_var}"
    fi
}

# Load secrets into local variables (not exported to env)
MYSQL_USER=$(get_secret "MYSQL_USER_FILE")
MYSQL_PASSWORD=$(get_secret "MYSQL_PASSWORD_FILE")
MYSQL_ROOT_PASSWORD=$(get_secret "MYSQL_ROOT_PASSWORD_FILE")
WP_USER=$(get_secret "WP_USER_FILE")
WP_USER_PASSWORD=$(get_secret "WP_USER_PASSWORD_FILE")
WP_ADMIN_USER=$(get_secret "WP_ADMIN_USER_FILE")
WP_ADMIN_PASSWORD=$(get_secret "WP_ADMIN_PASSWORD_FILE")

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

# Important if host port is not 443, and you want to use different port, can uncomment and try to bind a different port, you will see 502
echo "Configuring WordPress to handle ports correctly..."
wp config set WP_HOME "'https://' . \$_SERVER['HTTP_HOST']" --raw --allow-root --path="/var/www/html"
wp config set WP_SITEURL "'https://' . \$_SERVER['HTTP_HOST']" --raw --allow-root --path="/var/www/html"

# Ensure the Specialist (www-data) owns the Body before starting
chown -R www-data:www-data /var/www/html

# 3. Start PHP-FPM
echo "Starting PHP-FPM ${PHP_VERSION}"
exec php-fpm${PHP_VERSION} -F
