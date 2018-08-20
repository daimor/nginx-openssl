FROM nginx:alpine

RUN apk add --no-cache openssl 

COPY docker-entrypoint.sh makecert.sh /opt/
COPY default.conf /etc/nginx/conf.d/

WORKDIR /usr/share/nginx/html

EXPOSE 80 443

ENTRYPOINT [ "/opt/docker-entrypoint.sh" ]