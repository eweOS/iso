#!/bin/erv sh


mkdir -p rootfs

if [[ $PROFILE == liveimage* ]]; then
  _logtxt "#### creating boot partition"
  mkdir -p isofs
  dd if=/dev/zero of=bootfs.img bs=1M count=48
  mkfs.vfat ./bootfs.img
  $RUNAS mkdir -p ./rootfs/boot
  $RUNAS mount ./bootfs.img ./rootfs/boot
fi

_logtxt "#### bootstrapping system"

if [ ! -z $USEHOSTPKG ]; then
  USEHOSTPKG="-c"
fi

$RUNAS pacstrap -G -M $USEHOSTPKG -C ./pacman.ewe.conf ./rootfs `cat profiles/$PROFILE/packages.txt | xargs`

if [ -f profiles/$PROFILE/packages.$TARGET_ARCH.txt ]; then
  $RUNAS pacstrap -G -M $USEHOSTPKG -C ./pacman.ewe.conf ./rootfs `cat profiles/$PROFILE/packages.$TARGET_ARCH.txt | xargs`
fi

if [ -d profiles/$PROFILE/files ]; then
  _logtxt "#### copying files"
  $RUNAS cp -r profiles/$PROFILE/files ./rootfs/.files
fi

function concat_config() {
  for configsh in $1; do
    echo "echo \"#### setting up [`basename $configsh`]\"" >> $chrconf
    cat $configsh >> $chrconf
  done
}

_logtxt "#### setting up system"

chrconf=`mktemp`
echo "#!/bin/bash" > $chrconf
concat_config "./config/common/*.sh"
if [[ $PROFILE == liveimage* ]]; then
  concat_config "./config/liveimage/*.sh"
fi
if [[ $PROFILE == tarball* ]]; then
  concat_config "./config/tarball/*.sh"
fi
if [ -f "./profiles/$PROFILE/config.sh" ]; then
  cat ./profiles/$PROFILE/config.sh >> $chrconf
fi
crsh $chrconf

if [ -d ./rootfs/.files ]; then
  _logtxt "#### remove unused files"
  $RUNAS rm -r ./rootfs/.files
fi

sleep 3
$RUNAS umount ./rootfs/boot || true
$RUNAS umount ./rootfs/proc || true
