# SPDX-License-Identifier: GPL-2.0-or-later

### settings ###################################################################

# shellcheck shell=bash # no shebang as this file is intended to be sourced

### description ################################################################

# This file contains everything related to setup Pygments.

### variables ##################################################################

# https://pygments.org
PYGMENTS_PIP=pygments==2.8.1

### functions ##################################################################

function pygments_install
{
  pip3 install --prefix "$VER_DIR" "$PYGMENTS_PIP"
}
