#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: 2026 René de Hesselle <dehesselle@web.de>
#
# SPDX-License-Identifier: GPL-2.0-or-later

### description ################################################################

# Install CapyPDF.

### shellcheck #################################################################

# Nothing here.

### dependencies ###############################################################

source "$(dirname "${BASH_SOURCE[0]}")"/jhb/etc/jhb.conf.sh

### variables ##################################################################

SELF_DIR=$(dirname "$(greadlink -f "$0")")

### functions ##################################################################

# Nothing here.

### main #######################################################################

# Re-run the configuration because SDKROOT and MACOSX_DEPLOYMENT_TARGET
# are expected to have changed for CapyPDF.
# (SDK 15.5 targeting 13.3 for C++23 support)
jhb configure "$SELF_DIR"/modulesets/inkscape.modules

jhb build capypdf
