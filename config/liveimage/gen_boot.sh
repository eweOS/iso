cat <<EOF >/etc/tinyramfs/config
root=overlay
root_type=overlay
live_disk_type=label
live_disk=EWE_ISO
hooks=mdev,plymouth,live
compress='gzip -9'
ram=1
live_ram_opts="size=50%,mode=0755"
EOF

_bootloader_set=0

# plymouth
if [ ! -z "`pacman -Qeq | grep ^plymouth$`" ]; then
  echo "Found plymouth"
  # FIXME: use text mode since early KMS is not ready and unable to detect FB
  cat <<EOF>/etc/plymouth/plymouthd.conf
[Daemon]
Theme=tribar
EOF
fi

# limine bootloader
if [ ! -z "`pacman -Qeq | grep ^limine$`" ] && [ "$_bootloader_set"=="0" ]; then
  echo "Found limine"
  mkdir -p /boot/EFI/BOOT
  cp /usr/share/limine/*.EFI /boot/EFI/BOOT/
  limine-mkconfig -b "rolling (LiveCD)" -o /boot/limine.cfg
  # for hybrid iso
  if [ -f /usr/share/limine/limine-bios-cd.bin ]; then
    cp /usr/share/limine/{limine-bios-cd.bin,limine-bios.sys} /boot/
  fi
  cp /usr/share/limine/limine-uefi-cd.bin /boot/
  _bootloader_set=1
fi

