# SPDX-FileCopyrightText: 2021 René de Hesselle <dehesselle@web.de>
#
# SPDX-License-Identifier: GPL-2.0-or-later

### description ################################################################

# Convert svg to icns. This is the "wrapper" that utilizes/requires caivrosvg
# and png2icns packages.

### shellcheck #################################################################

# shellcheck shell=bash # no shebang as this file is intended to be sourced

### dependencies ###############################################################

source "$(dirname "${BASH_SOURCE[0]}")"/png2icns.sh

### variables ##################################################################

# Nothing here.

### functions ##################################################################

function svg2icns_install
{
  png2icns_install
}

function svg2icns
{
  local svg_file=$1
  local icns_file=$2

  local png_file
  png_file=$TMP_DIR/$(basename -s .svg "$svg_file").png

  # svg to png
  jhb run rsvg-convert -w 1024 -h 1024 "$svg_file" -o "$png_file"

  # png to icns
  cd "$TMP_DIR" || exit 1 # png2icns.sh outputs to current directory
  png2icns.sh "$png_file"

  mv "$(basename -s .png "$png_file")".icns "$icns_file"
}

### main #######################################################################

# Nothing here.
