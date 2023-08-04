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
  "$PKG_DIR"/numpy*.whl

#--------------------------------------------------------------------- run tests

cd "$INK_BLD_DIR" || exit 1

# run tests, but exclude *-data-directory because of
#     +[NSXPCSharedListener endpointForReply:withListenerName:]: an error
#     occurred while attempting to obtain endpoint for listener
#     'ClientCallsAuxiliary': Connection interrupted
ctest -V -E "(\
system-data-directory|\
user-data-directory\
)"
