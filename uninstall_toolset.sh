#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: 2021 René de Hesselle <dehesselle@web.de>
#
# SPDX-License-Identifier: GPL-2.0-or-later

### description ################################################################

# Uninstall a previously installed toolset: unmount the disk images.

### shellcheck #################################################################

# Nothing here.

### dependencies ###############################################################

source "$(dirname "${BASH_SOURCE[0]}")"/jhb/etc/jhb.conf.sh

bash_d_include echo
bash_d_include error

### variables ##################################################################

SELF_DIR=$(
  cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1
  pwd
)

### functions ##################################################################

function save_overlay
{
  local overlay
  overlay=$(diskutil list | grep "$RELEASE_OVERLAY" | grep "0:" |
    awk '{ print $5 }')
  umount /dev/"$overlay"

  diskutil mount \
    -mountOptions nobrowse,ro \
    -mountPoint "$TMP_DIR" \
    /dev/"$overlay"
  tar -C "$TMP_DIR" --exclude "Inkscape.???" --exclude ".fseventsd" -cp . |
    XZ_OPT=-T0 xz >"$ART_DIR"/toolset_overlay.tar.xz

  diskutil eject "$overlay"
}

### main #######################################################################

error_trace_enable

case "$1" in
  save_overlay) # save files from build stage (to be used later in test stage)
    save_overlay
    ;;
  save_testfiles) # save files from test stage (test evidence)
    tar -C "$INK_BLD_DIR" -cp testfiles Testing |
      XZ_OPT=-T0 xz >"$ART_DIR"/testfiles.tar.xz
    ;;
esac

"$SELF_DIR"/jhb/usr/bin/archive uninstall_dmg
