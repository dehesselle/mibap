# SPDX-License-Identifier: GPL-2.0-or-later

### settings ###################################################################

# shellcheck shell=bash # no shebang as this file is intended to be sourced

### description ################################################################

# This file contains everything related to setup Ninja build system.

### variables ##################################################################

# https://github.com/ninja-build/ninja
NINJA_VER=1.8.2
NINJA_URL=https://github.com/ninja-build/ninja/releases/download/v$NINJA_VER/\
ninja-mac.zip

### functions ##################################################################

function ninja_install
{
  if [ -f "$BIN_DIR"/ninja ]; then
    echo_i "already installed"
  else
    curl -o "$PKG_DIR"/"$(basename $NINJA_URL)" -L "$NINJA_URL"
    unzip -d "$BIN_DIR" "$PKG_DIR/$(basename "$NINJA_URL")"
  fi
}
