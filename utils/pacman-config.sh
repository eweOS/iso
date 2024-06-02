#!/bin/env sh

_logtxt "#### setting up pacman.conf"

if [ ! -f "pacman.ewe.conf" ]; then
  if [ "`cat /etc/os-release | grep ^ID || true`" != "ID=ewe" ]; then
    wget https://raw.githubusercontent.com/eweOS/packages/pacman/pacman.conf -O pacman.ewe.conf
  else
    $RUNAS pacman -Sy --noconfirm arch-install-scripts util-linux
    cp /etc/pacman.conf ./pacman.ewe.conf
  fi
fi
sed -i "s/Architecture = .*/Architecture = $TARGET_ARCH/g" pacman.ewe.conf
sed -i "s@Include = /etc/pacman.d/mirrorlist@Server = http://os-repo-auto.ewe.moe/eweos/\$repo/os/\$arch/@" pacman.ewe.conf
