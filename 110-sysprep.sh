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

echo_i "TOOLSET_ROOT_DIR = $TOOLSET_ROOT_DIR"
echo_i "WRK_DIR          = $WRK_DIR"

### check for presence of SDK ##################################################

if [ ! -d $SDKROOT ]; then
  echo_e "SDK not found: $SDKROOT"
  exit 1
fi

### create work directory ######################################################

if [ ! -d $WRK_DIR ]; then
  mkdir -p $WRK_DIR
fi

### create temporary directory #################################################

if [ ! -d $TMP_DIR ]; then
  mkdir -p $TMP_DIR
fi

### create binary directory #################################################

if [ ! -d $BIN_DIR ]; then
  mkdir -p $BIN_DIR
fi

### create toolset repository directory ########################################

if [ ! -d $TOOLSET_REPO_DIR ]; then
  mkdir -p $TOOLSET_REPO_DIR
fi
