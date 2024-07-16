#!/bin/erv sh

mkdir -p rootfs
PACSTRAP_ROOT=./rootfs

if [[ $PROFILE == liveimage* ]]; then
  mkdir -p basefs livefs tmpfs
  PACSTRAP_ROOT=./basefs
fi

_logtxt "#### bootstrapping system"

$RUNAS pacstrap -G -M -c -C ./pacman.ewe.conf ${PACSTRAP_ROOT} `cat profiles/$PROFILE/packages.txt | xargs`

if [ -f profiles/$PROFILE/packages.$TARGET_ARCH.txt ]; then
  $RUNAS pacstrap -G -M -c -C ./pacman.ewe.conf ${PACSTRAP_ROOT} `cat profiles/$PROFILE/packages.$TARGET_ARCH.txt | xargs`
fi

