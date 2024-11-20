#!/bin/bash

for srv in networkmanager greetd seatd; do
  dinitctl -s -o enable $srv
done

for srv in pipewire-pulse wireplumber; do
  ln -s ../$srv /usr/lib/dinit.d/user/boot.d
done

for grp in video input audio seat; do
  adduser ewe $grp
done

cp /.files/live-intro /usr/local/bin/live-intro
chmod +x /usr/local/bin/live-intro

cp /.files/boot.jpg /boot/bg.jpg

echo 'TERM_WALLPAPER=boot:///bg.jpg' >> /etc/default/limine
echo 'TERM_MARGIN=0' >> /etc/default/limine

limine-mkconfig -b "rolling (LiveCD)" -o /boot/limine.cfg
