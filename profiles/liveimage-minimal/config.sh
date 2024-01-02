#!/bin/bash

rm $0

sed -i 's/os-repo.ewe.moe/127.0.0.1:8085/' /etc/pacman.conf

echo "virtio_net" >>/etc/modules
echo "virtio_gpu" >>/etc/modules
echo "virtio_input" >>/etc/modules

ln -s /usr/lib/dinit.d/system/udhcpc /etc/dinit.d/boot.d

echo "eweos-live" >/etc/hostname
adduser -D ewe
echo 'root:$1$ewe$gaySV0Ar7d0prQ/1fYOKu0' | chpasswd -e || true
echo 'ewe:$1$ewe$gaySV0Ar7d0prQ/1fYOKu0' | chpasswd -e || true
echo 'ewe ALL=(ALL:ALL) NOPASSWD: ALL' >>/etc/sudoers

ln -s /usr/lib/dinit.d/system/greetd /etc/dinit.d/boot.d

cat <<EOF >>/etc/greetd/config.toml
[initial_session]
command = "bash -c 'cat /etc/motd && bash'"
user = "ewe"
EOF

touch /etc/fstab

cat <<EOF >/etc/tinyramfs/config
root=overlay
root_type=overlay
root_opts="lowerdir=/run/initramfs/system,upperdir=/run/initramfs/overlayfs/write,workdir=/run/initramfs/overlayfs/work"
live_disk_type=label
live_disk=EWE_ISO
live_img_file=/root.sfs
hooks=mdev,live
compress='gzip -9'
ram=1
live_ram_opts="size=50%,mode=0755"
EOF

cat <<EOF >/etc/motd

Welcome to eweOS!

This is a live image, ALL CHANGES WILL BE LOST when you reboot.

 * Mainpage: https://os.ewe.moe
 * Wiki:     https://os-wiki.ewe.moe
 * Packages: https://os.ewe.moe/pkglist

EOF

genefistub

echo "y" | pacman -Scc
