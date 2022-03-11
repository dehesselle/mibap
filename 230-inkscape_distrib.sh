#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: 2021 René de Hesselle <dehesselle@web.de>
#
# SPDX-License-Identifier: GPL-2.0-or-later

### description ################################################################

# Create a disk image for distribution.

### shellcheck #################################################################

# Nothing here.

### dependencies ###############################################################

source "$(dirname "${BASH_SOURCE[0]}")"/jhb/etc/jhb.conf.sh

source "$(dirname "${BASH_SOURCE[0]}")"/src/dmgbuild.sh
source "$(dirname "${BASH_SOURCE[0]}")"/src/ink.sh

bash_d_include error

### variables ##################################################################

SELF_DIR=$(dirname "$(greadlink -f "$0")")

### functions ##################################################################

# Nothing here.

### main #######################################################################

error_trace_enable

# Create background for development snapshots. This is not meant for
# official releases, those will be repackaged eventually (they also need
# to be signed and notarized).
LD_LIBRARY_PATH=$LIB_DIR convert -size 560x400 xc:transparent \
  -font Andale-Mono -pointsize 64 -fill black \
  -draw "text 20,60 'Inkscape'" \
  -draw "text 20,120 '$(ink_get_version)'" \
  -draw "text 20,180 'development'" \
  -draw "text 20,240 'snapshot'" \
  -draw "text 20,300 '$(ink_get_repo_shorthash)'" \
  "$SRC_DIR"/inkscape_dmg.png

# Create the disk image.
dmgbuild_run "$ARTIFACT_DIR"/Inkscape.dmg
