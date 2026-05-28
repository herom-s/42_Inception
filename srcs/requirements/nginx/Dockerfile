FROM alpine:3.22.4

RUN apk update \
	&& apk add --no-cache nginx openssl tini gettext-envsubst

RUN mkdir -p /etc/nginx/ssl

COPY ./conf/nginx.conf /etc/nginx/nginx.conf.template
COPY ./conf/openssl.conf /etc/nginx/ssl/openssl.conf.template

COPY ./tools/nginx-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/nginx-entrypoint.sh

EXPOSE 443

ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/nginx-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
