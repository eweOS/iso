#!/bin/bash

enable_service connman
enable_service nginx
enable_service fcgiwrap
enable_service cron
enable_service greetd

cp /etc/resolv.conf /etc/resolv.conf.bak
echo "nameserver 8.8.8.8" > /etc/resolv.conf

openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 \
    -subj "/C=CN/O=eweOS/OU=Test Server/CN=os-test.ewe.moe" \
    -keyout /etc/ssl/private/web.key  -out /etc/ssl/private/web.crt

mkdir -p /var/ewe

wget "https://raw.githubusercontent.com/eweOS/infra/main/test/gen.sh" -O /usr/local/bin/gen-web
chmod +x /usr/local/bin/gen-web

wget "https://raw.githubusercontent.com/eweOS/infra/main/test/pkg.cgi.sh" -O /var/ewe/pkg.cgi.sh
chmod +x /var/ewe/pkg.cgi.sh

cat <<EOF >/var/spool/cron/root
*/10 * * * * /usr/local/bin/gen-web
@reboot /usr/local/bin/gen-web
EOF

wget "https://raw.githubusercontent.com/eweOS/infra/main/test/server.conf" -O /etc/nginx/nginx.conf

mkdir -p /var/lib/connman

cat <<EOF >/var/lib/connman/eth.config
[global]
Name=eth

[service_eth0]
Type=ethernet
IPv4=192.168.1.104/24/192.168.1.1
IPv6=off
DeviceName=eth0
Nameservers=172.23.33.1

[service_eth1]
Type=ethernet
IPv4=off
IPv6=2a0d:2580:ff0c:1:57::104/56/2a0d:2580:ff0c::
DeviceName=eth1

EOF

mv /etc/resolv.conf.bak /etc/resolv.conf
