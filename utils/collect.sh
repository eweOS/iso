#!/bin/env sh

_logtxt "#### collecting result"

mkdir -p results

if [[ $PROFILE == liveimage* ]]; then
  mkdir -p ./tmpdir/isofs/live/sfs/
  $RUNAS mksquashfs ./tmpdir/rootfs ./tmpdir/isofs/live/sfs/root.sfs
  echo "root" | $RUNAS tee ./tmpdir/isofs/live/live.list
  if [ -f ./tmpdir/isofs/limine-bios-cd.bin ]; then
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
    tmpdir/isofs

  if [ ! -z "$BIOS_ARG" ]; then
    _logtxt "#### Install BIOS boot for ISO"
    # limine install bios
    $RUNAS mkdir -p ./tmpdir/rootfs/results
    $RUNAS mount --bind ./results ./tmpdir/rootfs/results
    $RUNAS arch-chroot ./tmpdir/rootfs bash -c "limine bios-install /results/eweos-$TARGET_ARCH-$PROFILE.iso"
    $RUNAS umount ./tmpdir/rootfs/results
    umount_chroot ./tmpdir/rootfs
  fi

  sha256sum results/eweos-$TARGET_ARCH-$PROFILE.iso > results/eweos-$TARGET_ARCH-$PROFILE.iso.sha256
fi

if [[ $PROFILE == tarball* ]]; then
  umount_chroot ./tmpdir/rootfs
  $RUNAS tar cJf results/eweos-$TARGET_ARCH-$PROFILE.tar.xz -C ./tmpdir/rootfs .
  pushd results
  sha256sum eweos-$TARGET_ARCH-$PROFILE.tar.xz > eweos-$TARGET_ARCH-$PROFILE.tar.xz.sha256
  popd
fi
