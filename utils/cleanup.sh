#!/bin/env sh

_logtxt "#### cleaning up env"

$RUNAS rm -r tmpdir || true

