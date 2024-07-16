#!/bin/erv sh

if [[ $PROFILE == liveimage* ]]; then
  $RUNAS mount -t overlay overlay -o lowerdir=$PWD/basefs,upperdir=$PWD/livefs,workdir=$PWD/tmpfs ./rootfs
  $RUNAS mkdir -p ./rootfs/boot ./isofs
  $RUNAS mount --bind ./isofs ./rootfs/boot
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

_logtxt "#### wait 3 sec to release mountpoint"
sleep 3
$RUNAS umount ./rootfs/boot || true
$RUNAS umount ./rootfs/proc || true

if [[ $PROFILE == liveimage* ]]; then
  $RUNAS sync
  $RUNAS umount ./rootfs
fi

