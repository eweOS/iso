#!/bin/env sh

_logtxt "#### setting up pacman.conf"

if [ ! -f "pacman.ewe.conf" ]; then
  if [ "`cat /etc/os-release | grep ^ID || true`" != "ID=ewe" ]; then
    wget https://raw.githubusercontent.com/eweOS/packages/pacman/pacman.conf -O pacman.ewe.conf
  else
    sudo pacman -Sy --noconfirm arch-install-scripts util-linux
    cp /etc/pacman.conf ./pacman.ewe.conf
  fi
fi
sed -i "s/Architecture = .*/Architecture = $TARGET_ARCH/g" pacman.ewe.conf
