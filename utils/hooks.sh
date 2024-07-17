#!/bin/env sh

if [[ $PROFILE == liveimage* ]]; then
  _logtxt "#### creating boot partition"
  mkdir -p tmpdir/isofs
  $RUNAS mkdir -p ./tmpdir/rootfs/boot
  $RUNAS mount --bind ./tmpdir/isofs ./tmpdir/rootfs/boot
fi

if [ -d profiles/$PROFILE/files ]; then
  _logtxt "#### copying files"
  $RUNAS cp -r profiles/$PROFILE/files ./tmpdir/rootfs/.files
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

if [ -d ./tmpdir/rootfs/.files ]; then
  _logtxt "#### remove unused files"
  $RUNAS rm -r ./tmpdir/rootfs/.files
fi

umount_chroot ./tmpdir/rootfs
