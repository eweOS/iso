#!/bin/env sh

_logtxt "#### cleaning up env"

sudo rm -r rootfs || true
sudo rm -r isofs || true
rm bootfs.img || true

