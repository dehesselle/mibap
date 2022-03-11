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
source "$(dirname "${BASH_SOURCE[0]}")"/src/ink.sh

bash_d_include error

### variables ##################################################################

# Nothing here.

### functions ##################################################################

# Nothing here.

### main #######################################################################

error_trace_enable

#----------------------------------------------------------- (re-) configure jhb

# Rerun configuration to adapt to the current system. This will
#   - allow Inkscape to be build against a different SDK than the toolset has
#     been built with
#   - setup ccache

jhb configure

#----------------------------------------------- install additional dependencies

jhb run pip3 install "$PKG_DIR"/lxml*.whl

#--------------------------------------------------------------------- run tests

cd "$INK_BLD_DIR" || exit 1

ninja tests   # build tests

ctest -V      # run tests
