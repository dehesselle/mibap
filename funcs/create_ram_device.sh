# SPDX-License-Identifier: GPL-2.0-or-later
#
# This file is part of the build pipeline for Inkscape on macOS.

# shellcheck shell=bash # no shebang as this file is intended to be sourced

### create a ramdisk and return the device #####################################

function create_ram_device
{
  local size_gib=$1   # unit is GiB
  local name=$2       # volume name

  if [ -z "$name" ]; then
    name=$(uuidgen | md5 | head -c 8)   # generate random name
  fi

  local size_sectors
  size_sectors=$((size_gib * 1024 * 2048))
  local device
  # use 'xargs' here to remove trailing spaces
  device=$(hdiutil attach -nomount ram://$size_sectors | xargs)
  newfs_hfs -v "$name" "$device" >/dev/null
  echo "$device"
}