#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later
#
# This file is part of the build pipeline for Inkscape on macOS.
#
# ### install_toolset.sh ###
# Install a pre-compiled version of the JHBuild toolset and required
# dependencies for Inkscape.

### load settings and functions ################################################

SELF_DIR=$(F=$0; while [ ! -z $(readlink $F) ] && F=$(readlink $F); \
  cd $(dirname $F); F=$(basename $F); [ -L $F ]; do :; done; echo $(pwd -P))
for script in $SELF_DIR/0??-*.sh; do source $script; done

set -e

### install build system #######################################################

function install
{
  echo_info "VERSION_WANT = $VERSION_WANT"
  echo_info "VERSION_HAVE = $VERSION_HAVE"

  if [ "$VERSION_WANT" = "$VERSION_HAVE" ]; then
    echo_ok "version ok"
  else
    # Version requirement has not been met, we have to install the required
    # build system version.
    
    echo_err "version mismatch"

    while : ; do   # unmount everything
      local disk=$(mount | grep $WRK_DIR | tail -n1 | awk '{ print $1 }')

      if [ ${#disk} -eq 0 ]; then
        break                  # nothing to do here
      else
        diskutil eject $disk > /dev/null   # unmount
        echo_ok "ejected $disk"
      fi
    done

    local buildsys_dmg=$REPOSITORY_DIR/$(basename $URL_BUILDSYS)

    if [ -f $buildsys_dmg ]; then
      echo_info "no download required"
    else
      # File not present on disk, we need to download.
      echo_act "download required"
      [ ! -d $REPOSITORY_DIR ] && mkdir -p $REPOSITORY_DIR
      save_file $URL_BUILDSYS $REPOSITORY_DIR
      echo_ok "download successful"
    fi

    # mount build system read-only
    [ -f $buildsys_dmg.shadow ] && rm $buildsys_dmg.shadow
    local device=$(create_dmg_device $buildsys_dmg -shadow)
    [ ! -d $WRK_DIR ] && mkdir -p $WRK_DIR
    mount -o nobrowse,rw -t hfs $device $WRK_DIR
    echo_ok "buildsystem mounted as $device"
  fi
}

### main #######################################################################

install

mkdir -p $HOME/.config
rm -f $HOME/.config/jhbuild*
ln -sf $DEVCONFIG/jhbuild* $HOME/.config
