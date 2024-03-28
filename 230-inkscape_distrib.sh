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

bash_d_include error

### variables ##################################################################

SELF_DIR=$(dirname "$(greadlink -f "$0")")

### functions ##################################################################

# Nothing here.

### main #######################################################################

error_trace_enable

# Create background for development snapshots.
LD_LIBRARY_PATH=$LIB_DIR convert \
  -size 440x404 canvas:transparent \
  -font Monaco -pointsize 32 -fill black \
  -draw "text 60,55 'Inkscape $(ink_get_version)'" \
  -draw "text 165,172 '>>>'" \
  -pointsize 18 \
  -draw "text 60,80 'commit $(ink_get_repo_shorthash)'" \
  -fill red \
  -draw "text 40,275 'Unsigned development version!'" \
  -pointsize 14 \
  -draw "text 40,292 'xattr -r -d com.apple.quarantine Inkscape.app'" \
  "$SRC_DIR"/inkscape_dmg.png

# Create the disk image.
dmgbuild_run "$SELF_DIR"/resources/inkscape_dmg.py "$INK_APP_PLIST"
