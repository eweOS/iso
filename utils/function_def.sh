#!/bin/env sh

function _logtxt() {
  echo "$(tput bold)${1}$(tput sgr0)"
}

function crsh(){
  cp $1 ./rootfs/config.sh && chmod +x ./rootfs/config.sh
  $RUNAS arch-chroot rootfs bash -c "/config.sh"
  $RUNAS rm ./rootfs/config.sh
}
