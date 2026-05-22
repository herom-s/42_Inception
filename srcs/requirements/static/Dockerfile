FROM alpine:3.22.4

RUN apk update && apk add --no-cache nginx tini gettext-envsubst

COPY ./www /var/www/static
COPY ./conf/nginx.conf /etc/nginx/nginx.conf.template

COPY ./tools/static-entrypoint.sh /usr/local/bin/static-entrypoint.sh
RUN chmod +x /usr/local/bin/static-entrypoint.sh

EXPOSE ${STATIC_PORT:-8081}

ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/static-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
