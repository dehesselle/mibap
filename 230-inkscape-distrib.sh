#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later
#
# This file is part of the build pipeline for Inkscape on macOS.
#
# ### 230-inkscape-distrib.sh ###
# Get application ready for distribution.

### load settings and functions ################################################

SELF_DIR=$(cd $(dirname "$0"); pwd -P)
for script in $SELF_DIR/0??-*.sh; do source $script; done

set -e

### create disk image for distribution #########################################

cp $SELF_DIR/inkscape_dmg.json $SRC_DIR

(
  # escaping forward slashes: https://unix.stackexchange.com/a/379577
  # ESCAPED=${STRING//\//\\\/}

  FILE=$SRC_DIR/inkscape_dmg.png
  sed -i '' "s/PLACEHOLDERBACKGROUND/${FILE//\//\\\/}/" $SRC_DIR/inkscape_dmg.json
  sed -i '' "s/PLACEHOLDERPATH/${APP_DIR//\//\\\/}/" $SRC_DIR/inkscape_dmg.json
)

# create background
convert -size 560x400 xc:transparent \
  -font Andale-Mono -pointsize 64 -fill black \
  -draw "text 20,60 'Inkscape'" \
  -draw "text 20,120 'development'" \
  -draw "text 20,180 'snapshot'" \
  -draw "text 20,240 '$(get_repo_version $INK_DIR)'" \
  $SRC_DIR/inkscape_dmg.png

(
  cd $SRC_DIR/node-*
  export PATH=$PATH:$(pwd)/bin
  appdmg $SRC_DIR/inkscape_dmg.json $ARTIFACT_DIR/Inkscape.dmg
)

if [ ! -z $CI_JOB_ID ]; then   # create build artifcat for CI job
  mv $ARTIFACT_DIR $INK_DIR/artifacts
  rm -rf $INK_DIR/artifacts/*.app
fi
