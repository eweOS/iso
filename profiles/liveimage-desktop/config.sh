#!/bin/bash

enable_service connman
enable_service greetd
enable_user_service pipewire-pulse

adduser ewe video
adduser ewe input
adduser ewe audio
adduser ewe seat
adduser greeter video
adduser greeter input
adduser greeter seat

cp /.files/live-intro /usr/local/bin/live-intro
chmod +x /usr/local/bin/live-intro

chown ewe:ewe -R /home/ewe/.config

cp /.files/boot.jpg /boot/bg.jpg

echo 'TERM_WALLPAPER=boot:///bg.jpg' >> /etc/default/limine
echo 'TERM_MARGIN=0' >> /etc/default/limine

limine-mkconfig -b "rolling (LiveCD)" -o /boot/limine.cfg
