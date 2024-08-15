#!/bin/env sh

for subprofile in $(ls profiles/$PROFILE/subprofiles); do

mount_overlay live-$subprofile live packages base

mkdir -p tmpdir/isofs/live

cat <<EOF | $RUNAS tee ./tmpdir/isofs/live/$subprofile.list
base
packages
live
live-$subprofile
EOF

if [ -f profiles/$PROFILE/subprofiles/$subprofile/packages.txt ]; then
  $RUNAS pacstrap -G -M -c -C ./pacman.ewe.conf ./tmpdir/rootfs `cat profiles/$PROFILE/subprofiles/$subprofile/packages.txt | xargs`
fi

if [ -d profiles/$PROFILE/subprofiles/$subprofile/files ]; then
  _logtxt "#### copying files"
  $RUNAS cp -r profiles/$PROFILE/subprofiles/$subprofile/files ./tmpdir/rootfs/.files
fi

if [ -f "./profiles/$PROFILE/subprofiles/$subprofile/config.sh" ]; then
  crsh ./profiles/$PROFILE/subprofiles/$subprofile/config.sh
fi

if [ -d ./tmpdir/rootfs/.files ]; then
  _logtxt "#### remove unused files"
  $RUNAS rm -r ./tmpdir/rootfs/.files
fi

umount_overlay

done

# read default subprofile from dir
if [ -f ./profiles/$PROFILE/default_subprofile.txt ]; then
  DEFAULT_SUBPROFILE=`cat ./profiles/$PROFILE/default_subprofile.txt`
# else just select first as default
else
  DEFAULT_SUBPROFILE=`ls profiles/$PROFILE/subprofiles | head -n 1`
fi

if [ -f ./tmpdir/isofs/live/${DEFAULT_SUBPROFILE}.list ]; then
  cp ./tmpdir/isofs/live/${DEFAULT_SUBPROFILE}.list ./tmpdir/isofs/live/live.list
fi
