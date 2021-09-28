#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: 2021 René de Hesselle <dehesselle@web.de>
#
# SPDX-License-Identifier: GPL-2.0-or-later

### description ################################################################

# Create our JHBuild-based toolset with all dependencies to be able to
# compile Inkscape.

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

set -e

for script in "$SELF_DIR"/1??-*.sh; do
  $script
done

# Our way of union-mounting a writable overlay ontop of a readonly filesystem
# introduces the additional challenge that paths cannot be written to if the
# parent path has not been written to (either a bug or a limitation, IDK).
# For most of the build system we work around that by re-creating the
# complete folder structure inside the writable overlay. In some cases
# we remove the paths causing problems.
rm -rf "$TMP_DIR"/wheels
