#!/bin/bash

enable_service connman
enable_service greetd

adduser ewe video
adduser ewe input
adduser greeter video
adduser greeter input

cat <<EOF >/etc/greetd/config.toml
[terminal]
vt=1

[default_session]
command = "wayfire"
user = "ewe"
EOF

mkdir -p /home/ewe/.config
cp /usr/share/wayfire/wayfire.ini /home/ewe/.config
sed -i 's/command_terminal = alacritty/command_terminal = foot/; s/# panel = wf-panel/panel = waybar/' \
	/home/ewe/.config/wayfire.ini
chown ewe:ewe -R /home/ewe/.config
