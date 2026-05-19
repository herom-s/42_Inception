FROM alpine:3.22.4

RUN apk update && apk add --no-cache redis tini gettext-envsubst

COPY ./tools/redis-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/redis-entrypoint.sh

COPY ./conf/redis.conf /etc/redis/redis.conf.template

EXPOSE 6379

ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/redis-entrypoint.sh"]
CMD ["redis-server", "/etc/redis/redis.conf"]

