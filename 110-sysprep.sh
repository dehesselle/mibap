#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later
#
# This file is part of the build pipeline for Inkscape on macOS.
#
# ### 110-sysprep.sh ###
# System preparation tasks.

### settings and functions #####################################################

# shellcheck disable=SC1090 # can't point to a single source here
for script in "$(dirname "${BASH_SOURCE[0]}")"/0??-*.sh; do source "$script"; done

#-- initial information --------------------------------------------------------

echo_i "WRK_DIR = $WRK_DIR"
echo_i "VER_DIR = $VER_DIR"

#-- create directories ---------------------------------------------------------

# We need these directories early on, so we need to create them ourselves.

mkdir -p "$HOME"
mkdir -p "$PKG_DIR"
mkdir -p "$SRC_DIR"
mkdir -p "$TMP_DIR"

#-- install ccache -------------------------------------------------------------

ccache_install
ccache_configure

#-- log relevant versions to release.log ---------------------------------------

mkdir -p "$VAR_DIR"/log

for var in MACOS_VER SDK_VER TOOLSET_VER WRK_DIR XCODE_VER; do
  echo "$var = $(eval echo \$$var)" >> "$VAR_DIR"/log/release.log
done
