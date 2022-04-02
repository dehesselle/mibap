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
# shellcheck disable=SC1091 # dynamic include
source "$SRC_DIR"/jhb/jhbuild.sh

bash_d_include error

source "$(dirname "${BASH_SOURCE[0]}")"/src/cairosvg.sh
source "$(dirname "${BASH_SOURCE[0]}")"/src/dmgbuild.sh
source "$(dirname "${BASH_SOURCE[0]}")"/src/png2icns.sh
source "$(dirname "${BASH_SOURCE[0]}")"/src/svg2icns.sh

### variables ##################################################################

# Nothing here.

### functions ##################################################################

# Nothing here.

### main #######################################################################

if $CI; then   # break in CI, otherwise we get interactive prompt by JHBuild
  error_trace_enable
fi

#---------------------------------------------------- install GNU Find Utilities

# We need this because the 'find' provided by macOS does not see the files
# in the lower (read-only) layer when we union-mount a ramdisk ontop of it.

jhb build findutils

#---------------------------------------------------- install disk image creator

dmgbuild_install

#-------------------------------------------- install application bundle creator

jhb build gtkmacbundler

#------------------------------------------------- install svg to icns convertor

svg2icns_install
