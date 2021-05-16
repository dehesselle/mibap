# SPDX-FileCopyrightText: 2021 René de Hesselle <dehesselle@web.de>
#
# SPDX-License-Identifier: GPL-2.0-or-later

### description ################################################################

# This file contains everything related to setup a custom Python runtime.

### settings ###################################################################

# shellcheck shell=bash # no shebang as this file is intended to be sourced

### variables ##################################################################

PYTHON_URL=https://github.com/dehesselle/py3framework/releases/download/\
py389.1/py389_framework_1.tar.xz

### functions ##################################################################

function python_install
{
  mkdir -p "$OPT_DIR"
  curl -L $PYTHON_URL | tar xz -C "$OPT_DIR"
  ln -s "$OPT_DIR"/Python.framework/Versions/Current/bin/python3.8 "$BIN_DIR"
  ln -s "$BIN_DIR"/python3.8 "$BIN_DIR"/python3
  ln -s "$OPT_DIR"/Python.framework/Versions/Current/bin/pip3 "$BIN_DIR"
}
