#!/bin/bash

cat <<EOF >/etc/greetd/config.toml
[terminal]
vt=7

[initial_session]
command = "/usr/lib/plasma-dbus-run-session-if-needed startplasma-wayland"
user = "ewe"

[default_session]
command = "/usr/local/bin/live-intro"
user = "ewe"
EOF

cat <<EOF >>/etc/environment
KWIN_FORCE_SW_CURSOR=1
EOF
