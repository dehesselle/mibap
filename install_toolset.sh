#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later
#
# This file is part of the build pipeline for Inkscape on macOS.
#
# ### install_toolset.sh ###
# Install a pre-compiled version of the JHBuild toolset and required
# dependencies for Inkscape.

### settings and functions #####################################################

# shellcheck disable=SC1090 # can't point to a single source here
for script in "$(dirname "${BASH_SOURCE[0]}")"/0??-*.sh; do source "$script"; done

include_file ansi_.sh
include_file echo_.sh
include_file error_.sh
error_trace_enable

# shellcheck disable=SC2034 # var is from ansi_.sh
ANSI_TERM_ONLY=false   # use ANSI control characters even if not in terminal

#-- install toolset ------------------------------------------------------------

function install
{
  local toolset_dmg
  toolset_dmg=$TOOLSET_REPO_DIR/$(basename "$TOOLSET_URL")

  if [ -f "$toolset_dmg" ]; then
    echo_i "toolset found: $toolset_dmg"
  else
    # File not present on disk, we need to download.
    echo_i "downloading: $TOOLSET_URL"
    download_url "$TOOLSET_URL" "$TOOLSET_REPO_DIR"
  fi

  echo_i "Mounting compressed disk image, this may take some time..."

  if [ ! -d "$VER_DIR" ]; then
    mkdir -p "$VER_DIR"
  fi

  # mount build system
  local device
  device=$(hdiutil attach -nomount "$toolset_dmg" | grep "^/dev/disk" |
    grep "Apple_HFS" | awk '{ print $1 }')
  mount -o nobrowse,noowners,ro -t hfs "$device" "$VER_DIR"
  echo_i "toolset mounted as $device"

  # Sadly, there are some limitations involved with union-mounting:
  #   - Files are not visible to 'ls'.
  #   - You cannot write in a location without having written to its
  #     parent location. That's why we need to pre-create all directories
  #     below.
  #
  # Shadow-mounting a dmg is not a feasible alternative due to its
  # bad write-performance.

  # prepare a script for mass-creating directories
  find "$VER_DIR" -type d ! -path "$VAR_DIR/*" ! -path "$SRC_DIR/*" \
      -exec echo "mkdir {}" \; > "$WRK_DIR"/create_dirs.sh
  echo "mkdir $BLD_DIR" >> "$WRK_DIR"/create_dirs.sh
  sed -i "" "1d" "$WRK_DIR"/create_dirs.sh   # remove first line ("file exists")
  chmod 755 "$WRK_DIR"/create_dirs.sh

  # create writable (ramdisk-) overlay
  # shellcheck disable=SC2086 # it's an integer
  device=$(create_ram_device $TOOLSET_OVERLAY_SIZE build)
  mount -o nobrowse,rw,union -t hfs "$device" "$VER_DIR"
  echo_i "writable overlay mounted as $device"

  # create all directories inside overlay
  "$WRK_DIR"/create_dirs.sh
  rm "$WRK_DIR"/create_dirs.sh
}

#-- main -----------------------------------------------------------------------

install
