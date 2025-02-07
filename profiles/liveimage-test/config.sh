#!/bin/bash

for srv in connman nginx fcgiwrap cron greetd; do
  dinitctl -s -o enable $srv
done

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

mv /etc/resolv.conf.bak /etc/resolv.conf
