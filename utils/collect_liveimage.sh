#!/bin/env sh

_logtxt "#### collecting result"

mkdir -p results

mkdir -p ./tmpdir/isofs/live/sfs/
for sfsdir in $(ls ./tmpdir/layers/); do
  $RUNAS mksquashfs ./tmpdir/layers/$sfsdir ./tmpdir/isofs/live/sfs/$sfsdir.sfs
done

# fallback if no default live option
if [ ! -f ./tmpdir/isofs/live/live.list ]; then
  cat <<EOF | $RUNAS tee ./tmpdir/isofs/live/live.list
base
packages
live
EOF
fi

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
  mount_overlay packages base
  $RUNAS mkdir -p ./tmpdir/rootfs/results
  $RUNAS mount --bind ./results ./tmpdir/rootfs/results
  $RUNAS arch-chroot ./tmpdir/rootfs bash -c "limine bios-install /results/eweos-$TARGET_ARCH-$PROFILE.iso"
  $RUNAS umount ./tmpdir/rootfs/results
  umount_overlay
fi

sha256sum results/eweos-$TARGET_ARCH-$PROFILE.iso > results/eweos-$TARGET_ARCH-$PROFILE.iso.sha256
