#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later
#
# This file is part of the build pipeline for Inkscape on macOS.
#
# ### create_ramdisk.sh ###
# Create a ramdisk to setup host machine for GitLab runner.

### load settings and functions ################################################

SELF_DIR=$(cd $(dirname "$0"); pwd -P)
for script in $SELF_DIR/0??-*.sh; do source $script; done

set -e

### create ramdisk #############################################################

create_ramdisk $WRK_DIR $RAMDISK_SIZE

