#!/bin/env sh

_logtxt "#### collecting result"

mkdir -p results

if [[ $PROFILE == liveimage* ]]; then
  mkdir -p ./isofs/live/sfs/
  $RUNAS mksquashfs ./rootfs ./isofs/live/sfs/root.sfs
  echo "root" | $RUNAS tee ./isofs/live/live.list
  if [ -f ./isofs/limine-bios-cd.bin ]; then
    BIOS_ARG="-b limine-bios-cd.bin"
  fi
  $RUNAS xorriso -as mkisofs \
    -o results/eweos-$TARGET_ARCH-$PROFILE.iso \
    $BIOS_ARG \
    -no-emul-boot -boot-load-size 4 -boot-info-table \
    --efi-boot limine-uefi-cd.bin \
    -efi-boot-part --efi-boot-image --protective-msdos-label \
    -V "EWE_ISO" \
    -A "eweOS Live ISO"  \
    isofs

  if [ ! -z "$BIOS_ARG" ]; then
    _logtxt "#### Install BIOS boot for ISO"
    # limine install bios
    $RUNAS mkdir -p ./rootfs/results
    $RUNAS mount --bind results ./rootfs/results
    $RUNAS arch-chroot rootfs bash -c "limine bios-install /results/eweos-$TARGET_ARCH-$PROFILE.iso"
    _logtxt "#### wait 3 sec to release mountpoint"
    sleep 3
    $RUNAS umount ./rootfs/proc || true
    $RUNAS umount ./rootfs/results
  fi

  sha256sum results/eweos-$TARGET_ARCH-$PROFILE.iso > results/eweos-$TARGET_ARCH-$PROFILE.iso.sha256
fi

if [[ $PROFILE == tarball* ]]; then
  # wait for arch-chroot to release mountpoint
  sleep 5
  # failsafe
  $RUNAS umount ./rootfs/sys/firmware/efi/efivars || true
  $RUNAS umount ./rootfs/sys || true
  $RUNAS tar cJf results/eweos-$TARGET_ARCH-$PROFILE.tar.xz -C ./rootfs .
  pushd results
  sha256sum eweos-$TARGET_ARCH-$PROFILE.tar.xz > eweos-$TARGET_ARCH-$PROFILE.tar.xz.sha256
  popd
fi
