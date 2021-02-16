#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later
#
# This file is part of the build pipeline for Inkscape on macOS.
#
# ### 110-sysprep.sh ###
# System preparation tasks.

### settings and functions #####################################################

for script in $(dirname ${BASH_SOURCE[0]})/0??-*.sh; do source $script; done

#-- initial information --------------------------------------------------------

echo_i "WRK_DIR = $WRK_DIR"
echo_i "VER_DIR = $VER_DIR"

#-- create directories ---------------------------------------------------------

# The following directories have been redirected so we need to create them.

mkdir -p $HOME
mkdir -p $TMP_DIR

#-- install ccache -------------------------------------------------------------

install_source $CCACHE_URL
configure_make_makeinstall

for compiler in clang clang++ gcc g++; do
  ln -s ccache $BIN_DIR/$compiler
done

configure_ccache $CCACHE_SIZE  # create directory and config file

#-- log relevant versions to release.log ---------------------------------------

mkdir -p $VAR_DIR/log

for var in MACOS_VER SDK_VER TOOLSET_VER WRK_DIR XCODE_VER; do
  echo "$var = $(eval echo \$$var)" >> $VAR_DIR/log/release.log
done
