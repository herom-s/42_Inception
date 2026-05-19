FROM alpine:3.22.4

RUN apk update && apk add --no-cache \
    php82 \
    php82-fpm \
    php82-mysqli \
    php82-json \
    php82-openssl \
    php82-curl \
    php82-zlib \
    php82-xml \
    php82-phar \
    php82-iconv \
	php82-pecl-redis \
    php82-tokenizer \
    mariadb-client \
    curl \
	gettext-envsubst \
    tini

RUN ln -s /usr/bin/php82 /usr/bin/php
RUN echo "memory_limit=512M" > /etc/php82/conf.d/memory_limit.ini

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

WORKDIR /var/www/html

COPY ./conf/wordpress.conf /etc/php82/php-fpm.d/www.conf.template
COPY ./tools/wordpress-entrypoint.sh /usr/local/bin/wordpress-entrypoint.sh
RUN chmod +x /usr/local/bin/wordpress-entrypoint.sh

EXPOSE 9000

ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/wordpress-entrypoint.sh"]
CMD ["php-fpm82", "-F"]
