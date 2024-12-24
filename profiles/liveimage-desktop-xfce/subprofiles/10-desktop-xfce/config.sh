#!/bin/bash

cat <<EOF >/etc/greetd/config.toml
[terminal]
vt=7

[initial_session]
command = "startxfce4 --wayland"
user = "ewe"

[default_session]
command = "/usr/local/bin/live-intro"
user = "ewe"
EOF

sudo -u ewe mkdir -p /home/ewe/.config/labwc

sudo -u ewe cat <<EOF >> /home/ewe/.config/labwc/autostart
activate-linux "Live Mode" "All changes will be lost after reboot" &
xfce4-terminal -e /usr/local/bin/live-intro &
xfconf-query -c xsettings -p /Net/IconThemeName -s Papirus &
EOF

sudo -u ewe cat <<EOF >> /home/ewe/.config/labwc/environment
# disable hw cursor (for VM)
WLR_NO_HARDWARE_CURSORS=1
# set gtk4 renderer (for VM)
GSK_RENDERER=gl
EOF

sudo -u ewe mkdir -p /home/ewe/Desktop
for dfile in xfce4-terminal gparted; do
  sudo -u ewe cp /usr/share/applications/$dfile.desktop /home/ewe/Desktop/
done
