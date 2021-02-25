# SPDX-License-Identifier: GPL-2.0-or-later

### settings and functions #####################################################

# shellcheck shell=bash # no shebang as this file is intended to be sourced
# shellcheck disable=SC2034 # globally defined variables here w/o export

### description ################################################################

# This file contains everything related to our usage of JHBuild.

### variables ##################################################################

# configuration files
export JHBUILDRC=$ETC_DIR/jhbuildrc
export JHBUILDRC_CUSTOM=$JHBUILDRC-custom

# JHBuild build system (3.38.0+ from master branch because of specific patch)
# https://gitlab.gnome.org/GNOME/jhbuild
# https://wiki.gnome.org/Projects/Jhbuild/Introduction
JHBUILD_VER=a896cbf404461cab979fa3cd1c83ddf158efe83b
JHBUILD_URL=https://gitlab.gnome.org/GNOME/jhbuild/-/archive/$JHBUILD_VER/\
jhbuild-$JHBUILD_VER.tar.bz2

### functions ##################################################################

function jhbuild_install
{
  install_source "$JHBUILD_URL"
  JHBUILD_DIR=$(pwd)

  # Create 'jhbuild' executable. This code has been adapted from
  # https://gitlab.gnome.org/GNOME/gtk-osx/-/blob/master/gtk-osx-setup.sh
  #
  # This file will use '/usr/bin/python3' instead of the environment lookup
  # '/usr/bin/env python3' because we want to stick with a version for
  # JHBuild regardless of what Python we install later (which would
  # replace that because of PATH within JHBuild environment).
  cat <<EOF > "$BIN_DIR/jhbuild"
#!/usr/bin/python3
# -*- coding: utf-8 -*-

import sys
import os
import builtins

sys.path.insert(0, '$JHBUILD_DIR')
pkgdatadir = None
datadir = None
import jhbuild
srcdir = os.path.abspath(os.path.join(os.path.dirname(jhbuild.__file__), '..'))

builtins.__dict__['PKGDATADIR'] = pkgdatadir
builtins.__dict__['DATADIR'] = datadir
builtins.__dict__['SRCDIR'] = srcdir

import jhbuild.main
jhbuild.main.main(sys.argv[1:])
EOF

  chmod 755 "$BIN_DIR"/jhbuild
}

function jhbuild_configure
{
  # Copy JHBuild configuration files. We can't use 'cp' because that doesn't
  # with the ramdisk overlay.
  mkdir -p "$(dirname "$JHBUILDRC")"
  # shellcheck disable=SC2094 # not the same file
  cat "$SELF_DIR"/jhbuild/"$(basename "$JHBUILDRC")"        > "$JHBUILDRC"
  # shellcheck disable=SC2094 # not the same file
  cat "$SELF_DIR"/jhbuild/"$(basename "$JHBUILDRC_CUSTOM")" > "$JHBUILDRC_CUSTOM"

  {
    # set moduleset directory
    echo "modulesets_dir = '$SELF_DIR/jhbuild'"
    echo "modulesets_dir = '$SELF_DIR/jhbuild'"

    # basic directory layout
    echo "buildroot = '$BLD_DIR'"
    echo "checkoutroot = '$SRC_DIR'"
    echo "prefix = '$VER_DIR'"
    echo "tarballdir = '$PKG_DIR'"

    # set macOS SDK
    echo "setup_sdk(sdkdir=\"$SDKROOT\")"

    # set release build
    echo "setup_release()"

    # enable ccache
    echo "os.environ[\"CC\"] = \"$BIN_DIR/gcc\""
    echo "os.environ[\"OBJC\"] = \"$BIN_DIR/gcc\""
    echo "os.environ[\"CXX\"] = \"$BIN_DIR/g++\""

    # certificates for https
    echo "os.environ[\"SSL_CERT_FILE\"] = \
    \"$LIB_DIR/python$PYTHON_SYS_VER/site-packages/certifi/cacert.pem\""
    echo "os.environ[\"REQUESTS_CA_BUNDLE\"] = \
    \"$LIB_DIR/python$PYTHON_SYS_VER/site-packages/certifi/cacert.pem\""

    # user home directory
    echo "os.environ[\"HOME\"] = \"$HOME\""

    # less noise on the terminal if not CI
    if ! $CI; then
      echo "quiet_mode = True"
      echo "progress_bar = True"
    fi

  } >> "$JHBUILDRC_CUSTOM"
}
