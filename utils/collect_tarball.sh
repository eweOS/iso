#!/bin/env sh

_logtxt "#### collecting result"

mkdir -p results

$RUNAS tar cJf results/eweos-$TARGET_ARCH-$PROFILE.tar.xz -C ./tmpdir/rootfs .
pushd results
sha256sum eweos-$TARGET_ARCH-$PROFILE.tar.xz > eweos-$TARGET_ARCH-$PROFILE.tar.xz.sha256
popd
