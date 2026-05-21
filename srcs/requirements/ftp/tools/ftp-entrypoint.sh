#!/bin/sh
set -e

FTP_USER=$(cat /run/secrets/ftp_user)
FTP_PASSWORD=$(cat /run/secrets/ftp_password)

mkdir -p /var/run/vsftpd/empty

envsubst '$FTP_PORT' < /etc/vsftpd/vsftpd.conf.template > /etc/vsftpd/vsftpd.conf

if ! id "$FTP_USER" > /dev/null 2>&1; then
    adduser -D -h /var/www/html -s /bin/sh "$FTP_USER"
    echo "$FTP_USER:$FTP_PASSWORD" | chpasswd
fi

exec "$@"
