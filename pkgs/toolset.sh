# SPDX-License-Identifier: GPL-2.0-or-later

### settings ###################################################################

# shellcheck shell=bash # no shebang as this file is intended to be sourced
# shellcheck disable=SC2034 # no exports desired

### description ################################################################

# This file contains everything related to the toolset.

### variables ##################################################################

TOOLSET_VER=$VERSION

# A disk image containing a built version of the whole toolset.
# https://github.com/dehesselle/mibap
TOOLSET_URL=https://github.com/dehesselle/mibap/releases/download/\
v$TOOLSET_VER/mibap_v${TOOLSET_VER}_stripped.dmg

TOOLSET_OVERLAY_SIZE=3   # writable ramdisk overlay, unit in GiB

TOOLSET_REPO_DIR=$WRK_DIR/repo   # persistent storage for downloaded dmg

### functions ##################################################################

function toolset_install
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

  # create writable ramdisk overlay
  device=$(hdiutil attach -nomount \
    ram://$((TOOLSET_OVERLAY_SIZE * 1024 * 2048)) | xargs)
  newfs_hfs -v "overlay" "$device" >/dev/null
  mount -o nobrowse,rw,union -t hfs "$device" "$VER_DIR"
  echo_i "writable overlay mounted as $device"

  # create all directories inside overlay
  "$WRK_DIR"/create_dirs.sh
  rm "$WRK_DIR"/create_dirs.sh
}

function toolset_uninstall
{
  while : ; do   # unmount everything (in reverse order)
    local disk
    disk=$(mount | grep "$VER_DIR" | tail -n1 | awk '{ print $1 }')

    if [ ${#disk} -eq 0 ]; then
      break   # nothing to do here
    else
      diskutil eject "$disk" > /dev/null   # unmount
      echo_i "ejected $disk"
    fi
  done
}

function toolset_build
{
  for script in "$SELF_DIR"/1??-*.sh; do
    $script
  done
}
