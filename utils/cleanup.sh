#!/bin/env sh

_logtxt "#### cleaning up env"

$RUNAS rm -r rootfs || true
$RUNAS rm -r isofs || true

