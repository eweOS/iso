#!/bin/env sh

for subprofile in $(ls profiles/$PROFILE/subprofiles); do

MOUNT_OVERLAY=(live packages base)

if [ -f profiles/$PROFILE/subprofiles/$subprofile/prev_profiles.txt ]; then
  MOUNT_OVERLAY=(`cat profiles/$PROFILE/subprofiles/$subprofile/prev_profiles.txt | xargs` "${MOUNT_OVERLAY[@]}")
fi

MOUNT_OVERLAY=($subprofile "${MOUNT_OVERLAY[@]}")

mount_overlay "${MOUNT_OVERLAY[@]}"

mkdir -p tmpdir/isofs/live
printf '%s\n' "${MOUNT_OVERLAY[@]}" | tac | $RUNAS tee ./tmpdir/isofs/live/$subprofile.list

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

# fallback option for "live"
DEFAULT_SUBPROFILE=`ls profiles/$PROFILE/subprofiles | head -n 1`

if [ -f ./tmpdir/isofs/live/${DEFAULT_SUBPROFILE}.list ]; then
  cp ./tmpdir/isofs/live/${DEFAULT_SUBPROFILE}.list ./tmpdir/isofs/live/live.list
fi
