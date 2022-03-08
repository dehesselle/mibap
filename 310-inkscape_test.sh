#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: 2021 René de Hesselle <dehesselle@web.de>
#
# SPDX-License-Identifier: GPL-2.0-or-later

### description ################################################################

# Run the test suite.

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

error_trace_enable

#-------------------------------------------------------- (re-) configure ccache

# This is required when using the precompiled toolset as ccache will not have
# been setup before (it happens in 110-sysprep.sh).

ccache_configure

#------------------------------------------------------- (re-) configure JHBuild

# This allows compiling Inkscape with a different setup than what the toolset
# was built with, most importantly a different SDK.

jhbuild_configure

#----------------------------------------------- install additional dependencies

jhbuild run pip3 install "$PKG_DIR"/lxml*.whl

#--------------------------------------------------------------------- run tests

cd "$INK_BLD_DIR" || exit 1

ninja tests   # build tests

ctest -V
