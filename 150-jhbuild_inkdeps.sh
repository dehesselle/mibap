#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: 2021 René de Hesselle <dehesselle@web.de>
#
# SPDX-License-Identifier: GPL-2.0-or-later

### description ################################################################

# Install remaining Inkscape dependencies, i.e. everything besides the GTK3
# stack.

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

#------------------------------------------------------ dependencies besides GTK

jhbuild build meta-inkscape-dependencies

#------------------------------------------------- run time dependencies: Python

# Download custom Python runtime.

ink_download_python

# Build Python wheels and save them to our package cache.

ink_build_wheels

# To provide backward compatibility, wheels are also built externally on a
# machine running the minimum supported OS version. CI takes care of
# acquiring those and puts them as wheels.tar.xz into PKG_DIR.