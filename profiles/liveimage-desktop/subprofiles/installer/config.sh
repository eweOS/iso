#!/bin/bash

cat <<EOF >/etc/greetd/config.toml
[terminal]
vt=7

[initial_session]
command = "cage -s -d -- jade-gui -f"
user = "ewe"

[default_session]
command = "/usr/local/bin/live-intro"
user = "ewe"
EOF

