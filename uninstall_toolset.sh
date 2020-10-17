#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later
#
# This file is part of the build pipeline for Inkscape on macOS.
#
# ### uninstall_toolset.sh ###
# Uninstall a previously installed toolset. In this case, "uninstall" means
# "unmount", the downloaded .dmg won't be deleted.

### load settings and functions ################################################

SELF_DIR=$(F=$0; while [ ! -z $(readlink $F) ] && F=$(readlink $F); \
  cd $(dirname $F); F=$(basename $F); [ -L $F ]; do :; done; echo $(pwd -P))
for script in $SELF_DIR/0??-*.sh; do source $script; done

include_file ansi_.sh
include_file echo_.sh
include_file error_.sh
error_trace_enable

ANSI_TERM_ONLY=false   # use ANSI control characters even if not in terminal

### uninstall toolset ##########################################################

function uninstall
{
    while : ; do   # unmount everything (in reverse order)
      local disk=$(mount | grep $VER_DIR | tail -n1 | awk '{ print $1 }')

      if [ ${#disk} -eq 0 ]; then
        break                              # nothing to do here
      else
        diskutil eject $disk > /dev/null   # unmount
        echo_i "ejected $disk"
      fi
    done
}

### main #######################################################################

uninstall
