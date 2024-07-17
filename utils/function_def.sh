#!/bin/env sh

function _logtxt() {
  echo "$(tput bold)${1}$(tput sgr0)"
}

function crsh(){
  cp $1 ./tmpdir/rootfs/config.sh && chmod +x ./tmpdir/rootfs/config.sh
  $RUNAS arch-chroot tmpdir/rootfs bash -c "/config.sh"
  $RUNAS rm ./tmpdir/rootfs/config.sh
}

function umount_chroot(){
  _logtxt "#### wait 3 sec to release mountpoint on $1"
  sleep 3
  $RUNAS umount $1/proc || true
  $RUNAS umount $1/boot || true
  $RUNAS umount $1/sys/firmware/efi/efivars || true
  $RUNAS umount $1/sys || true
}
