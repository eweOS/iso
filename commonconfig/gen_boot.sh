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
  genefistub
  _bootloader_set=1
fi

# limine bootloader
if [ ! -z "`pacman -Qeq | grep ^limine$`" ] && [ "$_bootloader_set"=="0" ]; then
  mkdir -p /boot/EFI/BOOT
  cp /usr/share/limine/BOOTX64.EFI /boot/EFI/BOOT/BOOTX64.EFI
  _limine_first=1
  cat <<EOF >/boot/limine.cfg
DEFAULT_ENTRY=1
TIMEOUT=5
EOF

  for kernel in /usr/lib/modules/*/ ; do
    if ! pacman -Qqo "${kernel}" > /dev/null 2>&1; then
      # if pkgbase does not belong to any package then skip this kernel
      continue
    fi
    pkgbase=$(pacman -Qqo "${kernel}" 2>/dev/null)
    tinyramfs -f -k ${kernel##/usr/lib/modules/} /boot/initramfs-${pkgbase}.img
    install -Dm644 "${kernel}/vmlinuz" "/boot/vmlinuz-${pkgbase}"
    kernelver=`basename $kernel`
    if [ "$_limine_first" == "1" ]; then
      cat <<EOF >>/boot/limine.cfg
:eweOS Rolling LiveCD (${kernelver})
    COMMENT=eweOS Rolling LiveCD

    PROTOCOL=linux
    KERNEL_PATH=boot:///vmlinuz-${pkgbase}
    KERNEL_CMDLINE=console=tty1 console=ttyS0,115200 2 quiet splash
    MODULE_PATH=boot:///initramfs-${pkgbase}.img

:eweOS Rolling LiveCD (Advanced Boot Options)
    COMMENT=Advanced Boot Options for eweOS Rolling

    ::eweOS Rolling (kernel ${kernelver})
        COMMENT=eweOS Rolling LiveCD (kernel ${kernelver})

        PROTOCOL=linux
        KERNEL_PATH=boot:///vmlinuz-${pkgbase}
        KERNEL_CMDLINE=console=tty1 console=ttyS0,115200 2 quiet splash
        MODULE_PATH=boot:///initramfs-${pkgbase}.img
EOF
      _limine_first=0
    else
      cat <<EOF >>/boot/limine.cfg
    ::eweOS Rolling (kernel ${kernelver})
	COMMENT=eweOS Rolling LiveCD (kernel ${kernelver})

        PROTOCOL=linux
        KERNEL_PATH=boot:///vmlinuz-${pkgbase}
        KERNEL_CMDLINE=console=tty1 console=ttyS0,115200 2 quiet splash
        MODULE_PATH=boot:///initramfs-${pkgbase.img}
EOF
    fi

  done

  _bootloader_set=1
fi

