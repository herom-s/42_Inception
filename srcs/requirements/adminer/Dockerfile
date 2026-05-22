FROM alpine:3.22.4

RUN apk update && apk add --no-cache php82 php82-fpm php82-pdo php82-pdo_mysql \
    php82-session php82-json php82-openssl php82-ctype tini curl nginx gettext-envsubst

RUN ln -s /usr/bin/php82 /usr/bin/php

RUN mkdir -p /var/www/adminer

RUN curl -Lo /var/www/adminer/index.php \
    https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php

COPY ./conf/nginx.conf /etc/nginx/nginx.conf.template
COPY ./conf/php-fpm.conf /etc/php82/php-fpm.d/www.conf
COPY ./tools/adminer-entrypoint.sh /usr/local/bin/adminer-entrypoint.sh
RUN chmod +x /usr/local/bin/adminer-entrypoint.sh

EXPOSE 8080

ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/adminer-entrypoint.sh"]
