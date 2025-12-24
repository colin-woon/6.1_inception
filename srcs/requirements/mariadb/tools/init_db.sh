#!/bin/bash
set -e # Exit instantly if any command failed

# FIX THIS SHIT
# 1. Idempotency check
if [ -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then
	echo "Database ${MYSQL_DATABASE} already initialized. Starting server..."
	exec mariadbd --user=mysql --datadir=/var/lib/mysql --bind-address=0.0.0.0
fi

echo "Initializing Database ${MYSQL_DATABASE}"

# 2. Start temporary server
mariadb-install-db --user=mysql --datadir=/var/lib/mysql
# & puts mariadb in background, $! gets the most recently executed process ID
mariadbd --user=mysql --datadir=/var/lib/mysql --skip-networking & PID="$!"

# 3. Polling
# Wait for DB to connect
echo "Waiting for MariaDB to be ready..."
until mysqladmin ping -h localhost --silent; do
	sleep 1
done

# 4. Check if the database variables are actually set (Safety Check)
if [ -z "$MYSQL_DATABASE" ]; then
    echo "Error: MYSQL_DATABASE is not set!"
    exit 1
fi

# 5. The SQL Injection (Now using variables!)
mariadb -u root <<_EOF_
-- strict mode off for init might save headaches, but let's be precise
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;

-- Create App User
CREATE USER IF NOT EXISTS \`${MYSQL_USER}\`@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO \`${MYSQL_USER}\`@'%';

-- Create Remote Root (The Missing Piece)
CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;

-- Fix Local Root
-- We use ALTER here because root@localhost is created by install-db without a password (socket auth)
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';

FLUSH PRIVILEGES;
_EOF_

# 6. CLeanly shutdown temporary server
echo "Shutting down temporary server"
mysqladmin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown
wait "$PID" # script will not execute next if previous PID was not shutdown properly

# 7. Start MariaDB as PID 1
echo "Replacing MariaDB as PID 1"
exec mariadbd --user=mysql --bind-address=0.0.0.0
