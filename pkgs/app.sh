# SPDX-License-Identifier: GPL-2.0-or-later

### settings and functions #####################################################

# shellcheck shell=bash # no shebang as this file is intended to be sourced
# shellcheck disable=SC2034 # no exports desired

### description ################################################################

# This file contains things related to build the application bundle.

### variables ##################################################################

APP_DIR=$ARTIFACT_DIR/Inkscape.app
APP_CON_DIR=$APP_DIR/Contents
APP_RES_DIR=$APP_CON_DIR/Resources
APP_FRA_DIR=$APP_CON_DIR/Frameworks
APP_BIN_DIR=$APP_RES_DIR/bin
APP_ETC_DIR=$APP_RES_DIR/etc
APP_EXE_DIR=$APP_CON_DIR/MacOS
APP_LIB_DIR=$APP_RES_DIR/lib

APP_SITEPKG_DIR=$APP_LIB_DIR/python$PYTHON_INK_VER/site-packages

### functions ##################################################################

function app_pipinstall
{
  local package=$1
  local options=$2   # optional

  local PATH_ORIGINAL=$PATH
  export PATH=$APP_FRA_DIR/Python.framework/Versions/Current/bin:$PATH

  # shellcheck disable=SC2086 # we need word splitting here
  pip$PYTHON_INK_VER_MAJOR install \
    --prefix "$APP_RES_DIR" \
    --ignore-installed \
    $options \
    $package

  export PATH=$PATH_ORIGINAL
}
