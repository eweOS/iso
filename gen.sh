#!/bin/bash

ISOARCH=x86_64
PROFILE=liveimage-minimal

ISOFILE=eweos-$ISOARCH-$PROFILE.iso

if [ ! -f "pacman.ewe.conf" ]; then
  wget https://raw.githubusercontent.com/eweOS/packages/pacman/pacman.conf -O pacman.ewe.conf
  sed -i "s/Architecture = auto/Architecture = $ISOARCH/g" pacman.ewe.conf
fi

function crsh(){
  echo $@
  sudo arch-chroot rootfs bash -c "$@"
}

sudo rm -r rootfs || true
sudo rm -r isofs || true
rm bootfs.img

mkdir -p rootfs
mkdir -p isofs
dd if=/dev/zero of=bootfs.img bs=1M count=128
mkfs.fat -F 32 ./bootfs.img

sudo mkdir -p ./rootfs/boot
sudo mount ./bootfs.img ./rootfs/boot

sudo pacstrap -G -M -C ./pacman.ewe.conf ./rootfs `cat profiles/$PROFILE/packages.txt | xargs`

cp ./profiles/$PROFILE/config.sh ./rootfs/config.sh && chmod +x ./rootfs/config.sh

crsh "/config.sh"

sudo umount ./rootfs/boot

sudo cp ./bootfs.img ./isofs/efi.img

sudo mksquashfs ./rootfs ./isofs/root.sfs

sudo xorriso -as mkisofs \
   -o $ISOFILE \
   -R -J -v -d -N \
   -x $ISOFILE \
   -hide-rr-moved \
   -no-emul-boot \
   -eltorito-platform efi \
   -eltorito-boot efi.img \
   -V "EWE_ISO" \
   -A "eweOS Live ISO"  \
   isofs

sha256sum $ISOFILE > $ISOFILE.sha256
