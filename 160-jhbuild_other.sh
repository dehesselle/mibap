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

# shellcheck disable=SC1090 # can't point to a single source here
for script in "$(dirname "${BASH_SOURCE[0]}")"/0??-*.sh; do
  source "$script";
done

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

jhbuild build findutils

#---------------------------------------------------- install disk image creator

dmgbuild_install

#-------------------------------------------- install application bundle creator

jhbuild build gtkmacbundler

#------------------------------------------------- install svg to icns convertor

svg2icns_install
