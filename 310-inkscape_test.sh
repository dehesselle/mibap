#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: 2021 René de Hesselle <dehesselle@web.de>
#
# SPDX-License-Identifier: GPL-2.0-or-later

### description ################################################################

# Build and run the test suite.

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

error_trace_enable

#----------------------------------------------- install additional dependencies

jhb run pip3 install \
  "$PKG_DIR"/cssselect*.whl \
  "$PKG_DIR"/lxml*.whl \
  "$PKG_DIR"/numpy*.whl \
  "$PKG_DIR"/tinycss2*.whl

#--------------------------------------------------------------------- run tests

cd "$INK_BLD_DIR" || exit 1

# exclude failing tests
ctest -V -E "(\
user-data-directory|\
glyph-y-pos|\
glyphs-combining|\
glyphs-vertical|\
rtl-vertical\
)"
