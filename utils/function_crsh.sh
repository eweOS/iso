#!/bin/env sh

function crsh(){
  cp $1 ./rootfs/config.sh && chmod +x ./rootfs/config.sh
  sudo arch-chroot rootfs bash -c "/config.sh"
  sudo rm ./rootfs/config.sh
}
