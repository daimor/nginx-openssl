#!/bin/sh

mkdir -p /opt/ssl

cd /opt/ssl/
/opt/makecert.sh

if [ ! -f /etc/nginx/conf.d/nginx.conf.template ]
then 
  mv /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/nginx.conf.template 
fi

envsubst < /etc/nginx/conf.d/nginx.conf.template > /etc/nginx/conf.d/default.conf 

if [ -f /etc/nginx/redirect.conf.template ]
then 
  envsubst < /etc/nginx/redirect.conf.template > /etc/nginx/redirect.conf 
else
  touch /etc/nginx/redirect.conf 
fi

nginx -g 'daemon off;'