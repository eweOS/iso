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
  $RUNAS umount $1/dev || true
}

function mount_overlay(){
# mount overlay only for liveimage, use rootfs as usual for other images
if [[ $PROFILE == liveimage* ]]; then
  mkdir -p ./tmpdir/overlay_workdir
  upperlayer=$1
  mkdir -p ./tmpdir/layers/$upperlayer ./tmpdir/rootfs
  shift 1
  if [ $# -eq 0 ]; then
    $RUNAS mount --bind ./tmpdir/layers/$upperlayer ./tmpdir/rootfs
  else
    LOWERLAYERS=""
    for layer in "$@"
    do
      mkdir -p ./tmpdir/layers/$layer
      LOWERLAYERS+="$PWD/tmpdir/layers/${layer}:"
    done
    $RUNAS mount -t overlay overlay -o lowerdir=${LOWERLAYERS%:},upperdir=$PWD/tmpdir/layers/$upperlayer,workdir=$PWD/tmpdir/overlay_workdir ./tmpdir/rootfs
  fi
fi
}

function umount_overlay(){
  $RUNAS sync
  umount_chroot ./tmpdir/rootfs
  $RUNAS umount ./tmpdir/rootfs || true
}
