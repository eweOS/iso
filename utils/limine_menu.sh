#!/bin/bash

count=`ls profiles/$PROFILE/subprofiles | wc -l`
CFGOUT=./tmpdir/isofs/limine.cfg
sudo rm $CFGOUT || true
# TODO: multiple kernel
kernel_file=`ls ./tmpdir/isofs/ | grep vmlinuz- | head -n 1`
initrd_file=`ls ./tmpdir/isofs/ | grep initramfs- | head -n 1`

function limine_menu_render_subprofile() {
  title="$1"
  subprofile_id="$2"
  cat <<EOF | $RUNAS tee -a $CFGOUT
:eweOS $TARGET_ARCH ($title)
    PROTOCOL=linux
    KERNEL_PATH=boot:///${kernel_file}
    KERNEL_CMDLINE=live=${subprofile_id} quiet splash
    MODULE_PATH=boot:///${initrd_file}
EOF
}

function limine_menu_render_subprofile_adv() {
  title="$1"
  subtitle="$2"
  subprofile_id="$3"
  cmdline="$4"
  cat <<EOF | $RUNAS tee -a $CFGOUT
    ::eweOS $TARGET_ARCH ($title, $subtitle)
        PROTOCOL=linux
        KERNEL_PATH=boot:///${kernel_file}
        KERNEL_CMDLINE=live=${subprofile_id} $cmdline
        MODULE_PATH=boot:///${initrd_file}

EOF
}

# only process if more than 1 subprofiles
if [ "$count" -gt "1" ]; then

cat <<EOF | $RUNAS tee -a $CFGOUT
TERM_WALLPAPER=boot:///bg.jpg
TERM_MARGIN=0

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
:eweOS $TARGET_ARCH [Advanced Boot Options]

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
:Resume Default Boot Sequence
    PROTOCOL=chainload_next

EOF

fi
