#!/bin/bash

enable_service connman
enable_service nginx
enable_service fcgiwrap
enable_service cron
enable_service greetd

openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 \
    -subj "/C=CN/O=eweOS/OU=Test Server/CN=os-test.ewe.moe" \
    -keyout /etc/ssl/private/web.key  -out /etc/ssl/private/web.crt

mkdir -p /var/ewe

cat <<EOE >/usr/local/bin/gen-web
#!/bin/bash

pacman -Sy

cat <<EOF > /tmp/www-info.html
<!DOCTYPE html>
<html>
<head>
<title>eweOS Test Server</title>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
</head>
<body>
<h1>eweOS Test Server</h1>
<hr />
<p>This server is powered by eweOS rolling.</p>
<p>If you need user account in this test platform, please ask in Matrix or Telegram.</p>

<pre>
EOF

fastfetch >> /tmp/www-info.html

cat <<EOF >> /tmp/www-info.html
\`free -h\`

\`df -hT\`

Total packages in repo: \`pacman -Sl | wc -l\`
-------------
Updated: \`date\`
\`cronnext\`
</pre>
</body>
</html>
EOF

cp /tmp/www-info.html /var/ewe/index.html
EOE
chmod +x /usr/local/bin/gen-web

cat <<EOE >/var/ewe/pkg.cgi.sh
#!/bin/env bash

PKGNAME=\${REQUEST_URI#/package/}

if [ -z "\${PKGNAME}" ]; then
cat << EOF
Content-type: text/plain

Usage: /package/<PackageName>
EOF
exit
fi

if [[ \$HTTP_USER_AGENT == *"curl"* ]]; then

cat << EOF
Content-type: text/plain

\`pacman -Si \$PKGNAME 2>&1\`
EOF

else

cat << EOF
Content-type: text/html

<html>
<head><title>Query for \$PKGNAME</title></head>
<body>
<pre>\`pacman -Si \$PKGNAME 2>&1\`</pre>
</body>
</html>
EOF

fi
EOE
chmod +x /var/ewe/pkg.cgi.sh

cat <<EOF >/var/spool/cron/root
*/10 * * * * /usr/local/bin/gen-web
@reboot /usr/local/bin/gen-web
EOF

cat <<EOF >/etc/nginx/nginx.conf

worker_processes 1;

events {
  worker_connections 1024;
}

http {
  include mime.types;
  default_type application/octet-stream;
  keepalive_timeout 65;
  server {
    listen [::]:80;
    listen [::]:443 ssl;
    ssl_certificate /etc/ssl/private/web.crt;
    ssl_certificate_key /etc/ssl/private/web.key;
    location / {
      root   /var/ewe;
      index  index.html;
    }
    location /package/ {
      root           /var/ewe;
      fastcgi_pass   unix:/var/run/fcgiwrap/socket;
      fastcgi_param  SCRIPT_FILENAME  \$document_root/pkg.cgi.sh;
      include        fastcgi_params;
    }
  }
}
EOF


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
