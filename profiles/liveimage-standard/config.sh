#!/bin/bash

enable_service connman
enable_service greetd

cat <<EOF >>/etc/greetd/config.toml
[initial_session]
command = "bash -c 'cat /etc/motd && bash'"
user = "ewe"
EOF
