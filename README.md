# nginx-openssl
---
## Example
```
docker run -d \
    -p 443:443 \
    -e HOST=demo \
    -e NGINX_SERVER_CONF="location /api/ { proxy_pass http://someserver/api/; }" \    
    daimor/nginx-openssl
```
will be available by url https://demo.localtest.me/, with redirection for `/api/` URL to the linked server