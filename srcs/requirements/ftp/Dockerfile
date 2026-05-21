FROM alpine:3.22.4

RUN apk update && apk add --no-cache vsftpd tini gettext-envsubst

COPY ./conf/ftp.conf /etc/vsftpd/vsftpd.conf.template

COPY ./tools/ftp-entrypoint.sh /usr/local/bin/ftp-entrypoint.sh
RUN chmod +x /usr/local/bin/ftp-entrypoint.sh

RUN mkdir -p /var/run/vsftpd/empty

EXPOSE 2121 21000-21010

ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/ftp-entrypoint.sh"]
CMD ["vsftpd", "/etc/vsftpd/vsftpd.conf"]
