#!/bin/bash

# 1. Start the service (The "Hack" way)
service mariadb start
sleep 5

# 2. Check if the database variables are actually set (Safety Check)
if [ -z "$MYSQL_DATABASE" ]; then
    echo "Error: MYSQL_DATABASE is not set!"
    exit 1
fi

# 3. The SQL Injection (Now using variables!)
mariadb -e "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;"
mariadb -e "CREATE USER IF NOT EXISTS \`${MYSQL_USER}\`@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"
mariadb -e "GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO \`${MYSQL_USER}\`@'%';"
mariadb -e "FLUSH PRIVILEGES;"

# 4. Shutdown and Restart
mysqladmin -u root shutdown
exec mariadbd
