FROM alpine:3.22.4

RUN apk update && apk add --no-cache nginx tini

COPY ./www /var/www/static
COPY ./conf/nginx.conf /etc/nginx/nginx.conf

EXPOSE 8081

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["nginx", "-g", "daemon off;"]
