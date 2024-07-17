#!/bin/env sh

mkdir -p tmpdir/rootfs

_logtxt "#### bootstrapping base system"

mount_overlay base

$RUNAS pacstrap -G -M -c -C ./pacman.ewe.conf ./tmpdir/rootfs base linux linux-firmware

umount_overlay

_logtxt "#### bootstrapping packages"

mount_overlay packages base

$RUNAS pacstrap -G -M -c -C ./pacman.ewe.conf ./tmpdir/rootfs `cat profiles/$PROFILE/packages.txt | xargs`

if [ -f profiles/$PROFILE/packages.$TARGET_ARCH.txt ]; then
  $RUNAS pacstrap -G -M -c -C ./pacman.ewe.conf ./tmpdir/rootfs `cat profiles/$PROFILE/packages.$TARGET_ARCH.txt | xargs`
fi

umount_overlay
