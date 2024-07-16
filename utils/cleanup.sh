#!/bin/env sh

_logtxt "#### cleaning up env"

$RUNAS rm -r rootfs || true
$RUNAS rm -r livefs || true
$RUNAS rm -r basefs || true
$RUNAS rm -r tmpfs || true
$RUNAS rm -r isofs || true

