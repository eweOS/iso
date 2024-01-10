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

_bootloader_set=0

# efistub
if [ ! -z "`pacman -Qeq | grep ^efistub-tools$`" ] && [ "$_bootloader_set"=="0" ]; then
  echo "Found efistub-tools"
  genefistub
  _bootloader_set=1
fi

# limine bootloader
if [ ! -z "`pacman -Qeq | grep ^limine$`" ] && [ "$_bootloader_set"=="0" ]; then
  echo "Found limine"
  mkdir -p /boot/EFI/BOOT
  cp /usr/share/limine/BOOTX64.EFI /boot/EFI/BOOT/BOOTX64.EFI
  limine-mkconfig "rolling (LiveCD)" > /boot/limine.cfg
  _bootloader_set=1
fi

