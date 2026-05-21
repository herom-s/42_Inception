FROM alpine:3.22.4

RUN apk update && apk add --no-cache curl tini wget

RUN curl -Lo /tmp/portainer.tar.gz \
    https://github.com/portainer/portainer/releases/download/2.21.0/portainer-2.21.0-linux-amd64.tar.gz \
    && tar -xzf /tmp/portainer.tar.gz -C /usr/local/bin --strip-components=1 \
    && rm /tmp/portainer.tar.gz

RUN mkdir -p /data

COPY ./tools/portainer-entrypoint.sh /usr/local/bin/portainer-entrypoint.sh
RUN chmod +x /usr/local/bin/portainer-entrypoint.sh

EXPOSE 9000

ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/portainer-entrypoint.sh"]
