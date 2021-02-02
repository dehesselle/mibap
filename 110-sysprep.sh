#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later
#
# This file is part of the build pipeline for Inkscape on macOS.
#
# ### 110-sysprep.sh ###
# System preparation tasks.

### settings and functions #####################################################

for script in $(dirname ${BASH_SOURCE[0]})/0??-*.sh; do source $script; done

### initial information ########################################################

echo_i "WRK_DIR = $WRK_DIR"
echo_i "VER_DIR = $VER_DIR"

### create directories #########################################################

# The following directories have been redirected so we need to create them.

mkdir -p $HOME
mkdir -p $TMP_DIR

### install ccache #############################################################

install_source $CCACHE_URL
configure_make_makeinstall

for compiler in clang clang++ gcc g++; do
  ln -s ccache $BIN_DIR/$compiler
done

configure_ccache $CCACHE_SIZE  # create directory and config file

### log build-relevant versions ################################################

mkdir -p $VAR_DIR/log
echo $MACOS_VER   > $VAR_DIR/log/MACOS_VER.log
echo $SDK_VER     > $VAR_DIR/log/SDK_VER.log
echo $TOOLSET_VER > $VAR_DIR/log/TOOLSET_VER.log
echo $WRK_DIR     > $VAR_DIR/log/WRK_DIR.log
echo $XCODE_VER   > $VAR_DIR/log/XCODE_VER.log
