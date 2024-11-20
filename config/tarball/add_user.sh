catnest

adduser -D ewe -g "Default User"
echo 'root:$1$ewe$gaySV0Ar7d0prQ/1fYOKu0' | chpasswd -e || true
echo 'ewe:$1$ewe$gaySV0Ar7d0prQ/1fYOKu0' | chpasswd -e || true
echo 'ewe ALL=(ALL:ALL) NOPASSWD: ALL' >>/etc/sudoers
