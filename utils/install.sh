#!/bin/env sh

mkdir -p rootfs

_logtxt "#### bootstrapping system"

$RUNAS pacstrap -G -M -c -C ./pacman.ewe.conf ./rootfs `cat profiles/$PROFILE/packages.txt | xargs`

if [ -f profiles/$PROFILE/packages.$TARGET_ARCH.txt ]; then
  $RUNAS pacstrap -G -M -c -C ./pacman.ewe.conf ./rootfs `cat profiles/$PROFILE/packages.$TARGET_ARCH.txt | xargs`
fi

