#!/bin/env sh

_logtxt "#### collecting result"

mkdir -p results

if [[ $PROFILE == liveimage* ]]; then
  sudo mksquashfs ./rootfs ./isofs/root.sfs
  sudo xorriso -as mkisofs \
    -o results/eweos-$TARGET_ARCH-$PROFILE.iso \
    -J -v -d -N \
    -x results/eweos-$TARGET_ARCH-$PROFILE.iso \
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
  sha256sum results/eweos-$TARGET_ARCH-$PROFILE.iso > results/eweos-$TARGET_ARCH-$PROFILE.iso.sha256
fi

if [[ $PROFILE == tarball* ]]; then
  # wait for arch-chroot to release mountpoint
  sleep 5
  # failsafe
  sudo umount ./rootfs/sys/firmware/efi/efivars || true
  sudo umount ./rootfs/sys || true
  sudo tar cJf results/eweos-$TARGET_ARCH-$PROFILE.tar.xz -C ./rootfs .
  pushd results
  sha256sum eweos-$TARGET_ARCH-$PROFILE.tar.xz > eweos-$TARGET_ARCH-$PROFILE.tar.xz.sha256
  popd
fi
