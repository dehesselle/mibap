#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later
#
# This file is part of the build pipeline for Inkscape on macOS.
#
# ### create_buildenv.sh ###
# create jhbuild environment for Inkscape

### source in settings and functions ###########################################

SELF_DIR=$(cd $(dirname "$0"); pwd -P)
for script in $SELF_DIR/0??-*.sh; do source $script; done

### download pre-built build environment or build from scratch #################

if $PREBUILT_BUILDENV_ENABLE &&
   [ "$WRK_DIR" = "$DEFAULT_SYSTEM_WRK_DIR" ]; then   # we're good to download
  if $RAMDISK_ENABLE; then
    create_ramdisk $WRK_DIR $RAMDISK_SIZE
  fi
  cd $WRK_DIR
  gdrive_download $URL_PREBUILT_BUILDENV
  tar xJf mibap*.tar.xz
  rm mibap*.tar.xz
else  # we need to build from scratch
  for script in $SELF_DIR/1??-*.sh; do
    $script
  done
fi
