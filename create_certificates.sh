#!/usr/bin/env bash

echo "Create root certificate"
openssl req -x509 -new -nodes -newkey rsa:2048 -keyout rootCA.key -out rootCA.pem -batch -subj "/C=US/ST=CA/O=Manager"

echo "Create manager certificate"
openssl req -new -nodes -newkey rsa:2048 -keyout sslmanager.key -out sslmanager.csr -subj '/C=US/CN=192.168.41.11'
echo "Sign manager certificate with root certificate"
openssl x509 -req -days 365 -in sslmanager.csr -CA rootCA.pem -CAkey rootCA.key -out sslmanager.cert -CAcreateserial

echo "Create agent certificate"
openssl req -new -nodes -newkey rsa:2048 -keyout sslagent.key -out sslagent.csr -subj '/C=US/CN=192.168.41.12'
echo "Sign agent certifacte with root certificate"
openssl x509 -req -days 365 -in sslagent.csr -CA rootCA.pem -CAkey rootCA.key -out sslagent.cert -CAcreateserial

echo "move all required certificates to module configuration"
mv sslmanager.key modules/hid/files/sslmanager.key
mv sslmanager.cert modules/hid/files/sslmanager.cert
mv rootCA.pem modules/hid/files/rootCA.pem
mv sslagent.key modules/hid/files/sslagent.key
mv sslagent.cert modules/hid/files/sslagent.cert
