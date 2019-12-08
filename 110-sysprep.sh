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

run_annotated

### create work directory ######################################################

[ ! -d $WRK_DIR ] && mkdir -p $WRK_DIR

### redirect to locations below WRK_DIR ########################################

mkdir -p $TMP_DIR

rm -rf $HOME/.cache   # used by jhbuild
ln -sf $TMP_DIR $HOME/.cache

rm -rf $HOME/.local   # used by gtk-mac-bundler
ln -sf $OPT_DIR $HOME/.local
