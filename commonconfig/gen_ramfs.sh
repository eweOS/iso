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

genefistub
