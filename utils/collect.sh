#!/bin/env sh

_logtxt "#### collecting result"

if [[ $PROFILE == liveimage* ]]; then
  sudo mksquashfs ./rootfs ./isofs/root.sfs
  sudo xorriso -as mkisofs \
    -o eweos-$TARGET_ARCH-$PROFILE.iso \
    -J -v -d -N \
    -x eweos-$TARGET_ARCH-$PROFILE.iso \
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
  sha256sum eweos-$TARGET_ARCH-$PROFILE.iso > eweos-$TARGET_ARCH-$PROFILE.iso.sha256
fi

if [[ $PROFILE == tarball* ]]; then
  # wait for arch-chroot to release mountpoint
  sleep 5
  sudo tar cJf eweos-$TARGET_ARCH-$PROFILE.tar.xz -C ./rootfs .
  sha256sum eweos-$TARGET_ARCH-$PROFILE.tar.xz > eweos-$TARGET_ARCH-$PROFILE.tar.xz.sha256
fi
