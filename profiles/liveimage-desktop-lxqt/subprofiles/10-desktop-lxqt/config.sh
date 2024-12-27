#!/bin/bash

cat <<EOF >/etc/greetd/config.toml
[terminal]
vt=7

[initial_session]
command = "startlxqtwayland"
user = "ewe"

[default_session]
command = "/usr/local/bin/live-intro"
user = "ewe"
EOF

sudo -u ewe cat <<EOF >> /usr/share/lxqt/wayland/labwc/autostart
activate-linux "Live Mode" "All changes will be lost after reboot" &
qterminal -e /usr/local/bin/live-intro &
find ~/Desktop/*.desktop -exec gio set {} "metadata::trust" true \\; &
EOF

# disable hw cursor (for VM)
sed -i 's/#WLR_NO_HARDWARE_CURSORS/WLR_NO_HARDWARE_CURSORS/' /usr/share/lxqt/wayland/labwc/environment
# set gtk4 renderer (for VM)
echo "GSK_RENDERER=gl" >> /usr/share/lxqt/wayland/labwc/environment

sudo -u ewe mkdir -p /home/ewe/.config/lxqt
sudo -u ewe cp /.files/lxqt/* /home/ewe/.config/lxqt/

sudo -u ewe mkdir -p /home/ewe/Desktop
for dfile in qterminal gparted; do
  sudo -u ewe cp /usr/share/applications/$dfile.desktop /home/ewe/Desktop/
done

sudo -u ewe sed -i 's@Exec=/@Exec=sudo -E /@' /home/ewe/Desktop/$dfile.desktop
