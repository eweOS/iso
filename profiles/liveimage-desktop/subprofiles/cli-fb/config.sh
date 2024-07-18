#!/bin/bash

cat <<EOF >/etc/greetd/config.toml
[terminal]
vt=7

[default_session]
command = "yaft_wall /live/bg.jpg"
user = "ewe"
EOF

