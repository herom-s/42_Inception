FROM alpine:3.22.4

RUN apk update \
	&& apk add --no-cache mariadb mariadb-client tini gettext-envsubst

RUN mkdir -p /var/run/mysqld /var/lib/mysql \
	&& chown -R mysql:mysql /var/run/mysqld /var/lib/mysql

COPY ./conf/mariadb.conf /etc/mariadb-server.cnf.template
COPY ./tools/mariadb-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/mariadb-entrypoint.sh

EXPOSE 3306

ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/mariadb-entrypoint.sh"]
CMD ["mariadbd", "--user=mysql", "--datadir=/var/lib/mysql"]
