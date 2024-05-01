#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: 2021 René de Hesselle <dehesselle@web.de>
#
# SPDX-License-Identifier: GPL-2.0-or-later

### description ################################################################

# Install additional tools that are no direct dependencies of Inkscape but that
# we need for e.g. packaging the application.

### shellcheck #################################################################

# Nothing here.

### dependencies ###############################################################

source "$(dirname "${BASH_SOURCE[0]}")"/jhb/etc/jhb.conf.sh

bash_d_include error

### variables ##################################################################

# Nothing here.

### functions ##################################################################

# Nothing here.

### main #######################################################################

if $CI; then # break in CI, otherwise we get interactive prompt by JHBuild
  error_trace_enable
fi

#-------------------------------------------- install application bundle creator

jhb build gtkmacbundler

# protect against removal during cleanup
basename "$SRC_DIR"/gtk-mac-bundler* >> "$SRC_DIR"/.keep
