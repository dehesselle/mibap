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

### variables ##################################################################

SELF_DIR=$(dirname "$(greadlink -f "$0")")

### functions ##################################################################

# Nothing here.

### main #######################################################################

error_trace_enable

# Create background for development snapshots.
gm convert \
  -size 440x404 \
  -font Monaco -pointsize 32 -fill black \
  -draw "text 60,55 'Inkscape $(ink_get_version)'" \
  -draw "text 165,172 '>>>'" \
  -pointsize 18 \
  -draw "text 60,80 'commit $(ink_get_repo_shorthash)'" \
  -fill red \
  -draw "text 40,275 'Unsigned development version!'" \
  -pointsize 14 \
  -draw "text 40,292 'xattr -r -d com.apple.quarantine Inkscape.app'" \
  xc:white \
  "$DIR_SRC"/inkscape_dmg.png

# Create the disk image.
venvtools_dmgbuild "$SELF_DIR"/resources/inkscape_dmg.py "$INK_APP_PLIST"
