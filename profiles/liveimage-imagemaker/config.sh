#!/bin/bash

enable_service greetd
enable_service connman
enable_service rsyncd

if [ -f /etc/resolv.conf ]; then
  mv /etc/resolv.conf /etc/resolv.conf.bak
fi

cat <<EOF >/etc/resolv.conf
nameserver 172.23.33.1
EOF

mkdir -p /build
git clone https://github.com/eweOS/iso /build

if [ -f /etc/resolv.conf.bak ]; then
  mv /etc/resolv.conf.bak /etc/resolv.conf
fi

sed -i 's/os-repo.ewe.moe/repo.nia.dn42/' /etc/pacman.conf

cat <<EOF >/root/build.sh
#!/bin/bash

PROFILE=${1:-liveimage-desktop}

pushd /build
for imgprofile in liveimage-desktop liveimage-minimal tarball; do
  ./gen.sh $PROFILE
done
popd
EOF

chmod +x /root/build.sh
