#!/bin/bash

count=`ls profiles/$PROFILE/subprofiles | wc -l`
CFGOUT=./tmpdir/isofs/limine.conf
sudo rm $CFGOUT || true
# TODO: multiple kernel
kernel_file=`ls ./tmpdir/isofs/ | grep vmlinuz- | head -n 1`
initrd_file=`ls ./tmpdir/isofs/ | grep initramfs- | head -n 1`

function limine_menu_render_subprofile() {
  title="$1"
  subprofile_id="$2"
  cat <<EOF | $RUNAS tee -a $CFGOUT
/eweOS $TARGET_ARCH ($title)
    protocol: linux
    kernel_path: boot():/${kernel_file}
    cmdline: live=${subprofile_id} quiet splash
    module_path: boot():/${initrd_file}
EOF
}

function limine_menu_render_subprofile_adv() {
  title="$1"
  subtitle="$2"
  subprofile_id="$3"
  cmdline="$4"
  cat <<EOF | $RUNAS tee -a $CFGOUT
//eweOS $TARGET_ARCH ($title, $subtitle)
    protocol: linux
    kernel_path: boot():/${kernel_file}
    cmdline: live=${subprofile_id} $cmdline
    module_path: boot():/${initrd_file}
EOF
}

# only process if more than 1 subprofiles
if [ "$count" -gt "1" ]; then

cat <<EOF | $RUNAS tee -a $CFGOUT
wallpaper: boot():/bg.jpg
term_margin: 0
EOF

if [ -f "profiles/$PROFILE/subprofiles/$DEFAULT_SUBPROFILE/title.txt" ]; then
  DEFAULT_SUBPROFILE_NAME=`cat profiles/$PROFILE/subprofiles/$DEFAULT_SUBPROFILE/title.txt`
else
  DEFAULT_SUBPROFILE_NAME=$DEFAULT_SUBPROFILE
fi

limine_menu_render_subprofile "$DEFAULT_SUBPROFILE_NAME" $DEFAULT_SUBPROFILE

for subprofile in $(ls profiles/$PROFILE/subprofiles); do
  if [ "$subprofile" != "$DEFAULT_SUBPROFILE" ]; then
    if [ -f "profiles/$PROFILE/subprofiles/$subprofile/title.txt" ]; then
      subprofile_name=`cat profiles/$PROFILE/subprofiles/$subprofile/title.txt`
    else
      subprofile_name=$subprofile
    fi
    limine_menu_render_subprofile "$subprofile_name" $subprofile
  fi
done

cat <<EOF | $RUNAS tee -a $CFGOUT
/eweOS $TARGET_ARCH [Advanced Boot Options]

EOF

for subprofile in $(ls profiles/$PROFILE/subprofiles); do
  if [ -f "profiles/$PROFILE/subprofiles/$subprofile/title.txt" ]; then
    subprofile_name=`cat profiles/$PROFILE/subprofiles/$subprofile/title.txt`
  else
    subprofile_name=$subprofile
  fi
  limine_menu_render_subprofile_adv "$subprofile_name" "low memory mode" $subprofile "ram=0 quiet splash"
done

cat <<EOF | $RUNAS tee -a $CFGOUT
/Resume Default Boot Sequence
    protocol: chainload_next
EOF

fi
