#!/bin/sh

[ -z "$HOST" ] && PUBLIC_CN="localtest.me" || PUBLIC_CN=$HOST
PUBLIC_NAME=localtest

COUNTY=""
STATE=""
LOCATION=""
ORGANISATION=""
ALT_NAMES=""
ROOT_CN="Testing Root"
RSA_KEY_NUMBITS="2048"
DAYS="365"

echo "Generating certificate for $PUBLIC_CN"

SUBJ="/C=$COUNTY/ST=$STATE/L=$LOCATION/O=$ORGANISATION"

if [ ! -f "root.crt" ]
then
  # generate root certificate
  ROOT_SUBJ="$SUBJ/CN=$ROOT_CN"

  openssl genrsa \
    -out "root.key" \
    "$RSA_KEY_NUMBITS"

  openssl req \
    -new \
    -key "root.key" \
    -out "root.csr" \
    -subj "$ROOT_SUBJ"

  openssl req \
    -x509 \
    -key "root.key" \
    -in "root.csr" \
    -out "root.crt" \
    -days "$DAYS"
else
  echo "ENTRYPOINT: root.crt already exists"
fi

if [ ! -f "server.key" ]
then
  # generate public rsa key
  openssl genrsa \
    -out "server.key" \
    "$RSA_KEY_NUMBITS"
else
  echo "ENTRYPOINT: server.key already exists"
fi

if [ ! -f "server.crt" ]
then
  # generate public certificate
  PUBLIC_SUBJ="$SUBJ/CN=$PUBLIC_CN"

  openssl req \
    -new \
    -key "server.key" \
    -out "server.csr" \
    -subj "$PUBLIC_SUBJ"

  # append public cn to subject alt names
  echo -e "extendedKeyUsage = serverAuth,clientAuth\n" \
          "subjectAltName = @alt_names\n" \
          "[alt_names]\n" \
          "DNS.1 = $PUBLIC_CN" > /tmp/public.ext
  let pos=1
  for name in ${ALT_NAMES//,/ }
  do
    let pos+=1
    echo "DNS.$pos = $name" >> /tmp/public.ext
  done

  openssl x509 \
    -req \
    -in "server.csr" \
    -CA "root.crt" \
    -CAkey "root.key" \
    -out "server.crt" \
    -CAcreateserial \
    -extfile /tmp/public.ext \
    -days "$DAYS"

  cat root.crt >> server.crt
else
  echo "ENTRYPOINT: server.crt already exists"
fi

