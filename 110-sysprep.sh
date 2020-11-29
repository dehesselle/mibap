#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later
#
# This file is part of the build pipeline for Inkscape on macOS.
#
# ### 110-sysprep.sh ###
# System preparation tasks.

### load settings and functions ################################################

SELF_DIR=$(F=$0; while [ ! -z $(readlink $F) ] && F=$(readlink $F); cd $(dirname $F); F=$(basename $F); [ -L $F ]; do :; done; echo $(pwd -P))
for script in $SELF_DIR/0??-*.sh; do source $script; done

### initial information ########################################################

echo_i "WRK_DIR = $WRK_DIR"
echo_i "VER_DIR = $VER_DIR"

### check for presence of SDK ##################################################

if [ ! -d $SDKROOT ]; then
  echo_e "SDK not found: $SDKROOT"
  exit 1
fi

### create version directory ###################################################

if [ ! -d $VER_DIR ]; then
  mkdir -p $VER_DIR
fi

### create temporary directory #################################################

if [ ! -d $TMP_DIR ]; then
  mkdir -p $TMP_DIR
fi

### install ccache #############################################################

install_source $URL_CCACHE
configure_make_makeinstall

cd $BIN_DIR
ln -s ccache clang
ln -s ccache clang++
ln -s ccache gcc
ln -s ccache g++
