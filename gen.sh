#!/bin/bash

TARGET_ARCH=${2:-x86_64}
PROFILE=${1:-tarball-minimal}

. utils/log.sh
. utils/pacman-config.sh
. utils/function_crsh.sh
. utils/cleanup.sh
. utils/install.sh
. utils/collect.sh
