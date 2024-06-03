#!/bin/bash

RUNAS=${3:-sudo}
TARGET_ARCH=${2:-x86_64}
PROFILE=${1:-liveimage-minimal}

USEHOSTPKG=1

if [ ! -d ./profiles/$PROFILE ]; then
  echo "error: no such profile"
  exit 1
fi

errorhandler () {
  . utils/cleanup.sh
  exit 1
}

trap errorhandler ERR

. utils/log.sh
. utils/pacman-config.sh
. utils/cleanup.sh
. utils/function_crsh.sh
. utils/install.sh
. utils/collect.sh
. utils/cleanup.sh

