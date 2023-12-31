#!/bin/bash

ISOARCH=${2:-x86_64}
PROFILE=${1:-liveimage-minimal}

ISOFILE=eweos-$ISOARCH-$PROFILE.iso

if [ ! -f "pacman.ewe.conf" ]; then
  if [ "`cat /etc/os-release | grep ^ID || true`" != "ID=ewe" ]; then
    wget https://raw.githubusercontent.com/eweOS/packages/pacman/pacman.conf -O pacman.ewe.conf
  else
    sudo pacman -Sy --noconfirm libisoburn squashfs-tools arch-install-scripts e2fsprogs util-linux
    cp /etc/pacman.conf ./pacman.ewe.conf
  fi
  sed -i "s/Architecture = auto/Architecture = $ISOARCH/g" pacman.ewe.conf
fi

function crsh(){
  cp $1 ./rootfs/config.sh && chmod +x ./rootfs/config.sh
  sudo arch-chroot rootfs bash -c "/config.sh"
  sudo rm ./rootfs/config.sh
}

sudo rm -r rootfs || true
sudo rm -r isofs || true
rm bootfs.img

mkdir -p rootfs
mkdir -p isofs
dd if=/dev/zero of=bootfs.img bs=1M count=48
mkfs.vfat ./bootfs.img

sudo mkdir -p ./rootfs/boot
sudo mount ./bootfs.img ./rootfs/boot

sudo pacstrap -G -M -c -C ./pacman.ewe.conf ./rootfs `cat profiles/$PROFILE/packages.txt | xargs`

chrconf=`mktemp`
echo "#!/bin/bash" > $chrconf
for configsh in ./commonconfig/*.sh; do
  echo "echo \"#### setting up [`basename $configsh`]\"" >> $chrconf
  cat $configsh >> $chrconf
done
cat ./profiles/$PROFILE/config.sh >> $chrconf
crsh $chrconf

sudo umount ./rootfs/boot

sudo mksquashfs ./rootfs ./isofs/root.sfs

sudo xorriso -as mkisofs \
   -o $ISOFILE \
   -J -v -d -N \
   -x $ISOFILE \
   -partition_offset 16 \
   -no-pad \
   -hide-rr-moved \
   -no-emul-boot \
   -append_partition 2 0xef bootfs.img \
   -appended_part_as_gpt \
   -eltorito-platform efi \
   -e --interval:appended_partition_2:all:: \
   -V "EWE_ISO" \
   -A "eweOS Live ISO"  \
   -iso-level 3 \
   -partition_cyl_align all \
   isofs

sha256sum $ISOFILE > $ISOFILE.sha256
