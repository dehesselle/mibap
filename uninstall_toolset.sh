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

# shellcheck disable=SC1090 # can't point to a single source here
for script in "$(dirname "${BASH_SOURCE[0]}")"/0??-*.sh; do
  source "$script";
done

### variables ##################################################################

# Nothing here.

### functions ##################################################################

# Nothing here.

### main #######################################################################

error_trace_enable

case "$1" in
  save_overlay) # save files from build stage (to be used later in test stage)
    toolset_save_overlay
    ;;
  save_testfiles) # save files from test stage (test evidence)
    tar -C "$VAR_DIR" -cp testfiles |
      XZ_OPT=-T0 xz > "$ARTIFACT_DIR"/testfiles.tar.xz
    ;;
esac

toolset_uninstall