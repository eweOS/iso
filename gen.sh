#!/bin/bash

TARGET_ARCH=${2:-x86_64}
PROFILE=${1:-liveimage-minimal}

USEHOSTPKG=1

if [ ! -d ./profiles/$PROFILE ]; then
  echo "error: no such profile"
  exit 1
fi

. utils/log.sh
. utils/pacman-config.sh
. utils/function_crsh.sh
. utils/cleanup.sh
. utils/install.sh
. utils/collect.sh
