# SPDX-FileCopyrightText: 2021 René de Hesselle <dehesselle@web.de>
#
# SPDX-License-Identifier: GPL-2.0-or-later

### description ################################################################

# Convert svg to icns. This is a convenience wrapper around rsvg-convert
# and macOS system utilities.

### shellcheck #################################################################

# shellcheck shell=bash # no shebang as this file is intended to be sourced

### dependencies ###############################################################

# Nothing here.

### variables ##################################################################

# Nothing here.

### functions ##################################################################

function svg2icns
{
  local svg_file=$1
  local icns_file=$2

  local png_file
  png_file=$TMP_DIR/$(basename -s .svg "$svg_file").png

  # svg to png
  jhb run rsvg-convert -w 1024 -h 1024 "$svg_file" -o "$png_file"

  # png to icns
  local iconset
  iconset=$TMP_DIR/$(basename -s .icns "$icns_file").iconset
  mkdir "$iconset"
  for resolution in 1024 512 256 128 64 32 16; do
    sips -s format png --resampleWidth $resolution "$png_file" \
      --out "$iconset"/icon_${resolution}x${resolution}.png >/dev/null 2>&1
  done
  mv "$iconset"/icon_1024x1024.png "$iconset"/icon_512x512@2x.png
  cp "$iconset"/icon_512x512.png "$iconset"/icon_256x256@2x.png
  cp "$iconset"/icon_256x256.png "$iconset"/icon_128x128@2x.png
  mv "$iconset"/icon_64x64.png "$iconset"/icon_32x32@2x.png
  cp "$iconset"/icon_32x32.png "$iconset"/icon_16x16@2x.png
  iconutil -c icns -o "$icns_file" "$iconset"
}

### main #######################################################################

# Nothing here.
