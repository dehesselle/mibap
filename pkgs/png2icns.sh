# SPDX-License-Identifier: GPL-2.0-or-later

### settings and functions #####################################################

# shellcheck shell=bash # no shebang as this file is intended to be sourced

### description ################################################################

# Convert png to icns.

### variables ##################################################################

# https://github.com/bitboss-ca/png2icns
PNG2ICNS_VER=0.1
PNG2ICNS_URL=https://github.com/bitboss-ca/png2icns/archive/\
v$PNG2ICNS_VER.tar.gz

### functions ##################################################################

function png2icns_install
{
  install_source "$PNG2ICNS_URL"
  ln -s "$(pwd)"/png2icns.sh "$BIN_DIR"
}
