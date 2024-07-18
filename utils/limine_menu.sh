#!/bin/bash

count=`ls profiles/$PROFILE/subprofiles | wc -l`
CFGOUT=./tmpdir/isofs/limine.cfg
sudo rm $CFGOUT || true
kernel_file=`ls ./tmpdir/isofs/ | grep vmlinuz- | head -n 1`
initrd_file=`ls ./tmpdir/isofs/ | grep initramfs- | head -n 1`

function limine_menu_render_subprofile() {
  title="$1"
  cat <<EOF | $RUNAS tee -a $CFGOUT
:eweOS $PROFILE ($title)
    PROTOCOL=linux
    KERNEL_PATH=boot:///${kernel_file}
    KERNEL_CMDLINE=live=$title quiet splash
    MODULE_PATH=boot:///${initrd_file}
EOF
}

function limine_menu_render_subprofile_adv() {
  title="$1"
  subtitle="$2"
  cmdline="$3"
  cat <<EOF | $RUNAS tee -a $CFGOUT
    ::eweOS $PROFILE ($title, $subtitle)
        PROTOCOL=linux
        KERNEL_PATH=boot:///${kernel_file}
        KERNEL_CMDLINE=live=$title $cmdline
        MODULE_PATH=boot:///${initrd_file}

EOF
}

# only process if more than 1 subprofiles
if [ "$count" -gt "1" ]; then

cat <<EOF | $RUNAS tee -a $CFGOUT
TERM_WALLPAPER=boot:///bg.jpg
TERM_MARGIN=0

EOF

limine_menu_render_subprofile $DEFAULT_SUBPROFILE

for subprofile in $(ls profiles/$PROFILE/subprofiles); do
  if [ "$subprofile" != "$DEFAULT_SUBPROFILE" ]; then
    limine_menu_render_subprofile $subprofile
  fi
done

cat <<EOF | $RUNAS tee -a $CFGOUT
:eweOS $PROFILE (Advanced Boot Options)

EOF

for subprofile in $(ls profiles/$PROFILE/subprofiles); do
    limine_menu_render_subprofile_adv $subprofile "recovery mode" "nosplash -- single"
done

fi
