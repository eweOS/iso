#!/bin/bash

enable_service greetd
enable_service connman
enable_service rsyncd

mkdir -p /build
git clone https://github.com/eweOS/iso /build
