#!/bin/sh

FTP_PASSWORD=$(cat $FTP_PASSWORD_FILE)

# Create user if it doenst exist
# Force UID to 33 to match www-data in WordPress
adduser -D -h /var/www/html -u 33 $FTP_USER
echo "$FTP_USER:$FTP_PASSWORD" | chpasswd

chown -R $FTP_USER:$FTP_USER /var/www/html

echo "FTP Server starting for user $FTP_USER..."
exec /usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf