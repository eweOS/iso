cat <<EOF >/etc/tinyramfs/config
root=overlay
root_type=overlay
live_disk_type=label
live_disk=EWE_ISO
hooks=mdev,plymouth,live
modules_copy=config
modules_list="fs lib arch crypto \
  drivers/input/keyboard \
  drivers/md drivers/ata drivers/scsi drivers/block \
  drivers/virtio drivers/usb/host drivers/usb/storage drivers/mmc \
  drivers/gpu/drm/i915 drivers/gpu/drm/virtio"
compress='gzip -9'
live_ram=1
live_ram_opts="size=50%,mode=0755"
EOF

limine-install --removable --no-nvram
limine-mkconfig -b "rolling (LiveCD)" -o /boot/limine.conf

# for hybrid iso
if [ -f /usr/share/limine/limine-bios-cd.bin ]; then
  cp /usr/share/limine/{limine-bios-cd.bin,limine-bios.sys} /boot/
fi
cp /usr/share/limine/limine-uefi-cd.bin /boot/
