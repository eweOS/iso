#!/bin/bash

cat <<EOF >/etc/greetd/config.toml
[terminal]
vt=7

[initial_session]
command = "Hyprland"
user = "ewe"

[default_session]
command = "/usr/local/bin/live-intro"
user = "ewe"
EOF

mkdir -p /home/ewe/.config/hypr /home/ewe/.config/foot
cp /usr/share/hyprland/hyprland.conf /home/ewe/.config/hypr/hyprland.conf
sed -i 's/autogenerated=1//; s/kitty/foot/; s/wofi --show drun/rofi -show drun -show-icons -terminal foot/; /dwindle {/a no_gaps_when_only = 1' \
        /home/ewe/.config/hypr/hyprland.conf
cp -r /etc/xdg/foot/foot.ini /home/ewe/.config/foot/foot.ini
sed -i 's/# alpha=1.0/ alpha=0.3/' /home/ewe/.config/foot/foot.ini
mkdir -p /home/ewe/.config/waybar

cp /.files/waybar/config.jsonc /home/ewe/.config/waybar/config.jsonc

cat <<EOF >>/home/ewe/.config/hypr/hyprland.conf
exec-once = waybar & swww init
exec-once = fcitx5
exec-once = foot live-intro
exec-once = activate-linux "Live Mode" "All changes will be lost after reboot"
EOF
