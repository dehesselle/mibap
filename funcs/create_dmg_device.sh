# SPDX-License-Identifier: GPL-2.0-or-later
#
# This file is part of the build pipeline for Inkscape on macOS.

# shellcheck shell=bash # no shebang as this file is intended to be sourced

### attach a disk image and return the device ##################################

function create_dmg_device
{
  local dmg=$1
  local options=$2   # optional arguments for hdiutil

  local device
  # shellcheck disable=SC2086 # options is allowed to be empty
  device=$(hdiutil attach -nomount "$dmg" $options | grep "^/dev/disk" |
    grep "Apple_HFS" | awk '{ print $1 }')

  echo "$device"
}