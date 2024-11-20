#!/bin/bash

dinitctl -s -o enable connman
dinitctl -s -o enable greetd

cat <<EOF >>/etc/greetd/config.toml
[initial_session]
command = "bash -c 'cat /etc/motd && bash'"
user = "ewe"
EOF
