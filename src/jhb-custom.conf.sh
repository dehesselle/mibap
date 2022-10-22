#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: 2022 René de Hesselle <dehesselle@web.de>
#
# SPDX-License-Identifier: GPL-2.0-or-later

### description ################################################################

# Custom configuration for jhb.

### shellcheck #################################################################

# shellcheck disable=SC2034 # no unused variables

### dependencies ###############################################################

# Nothing here.

### variables ##################################################################

VERSION=0.69
VER_DIR_TEMPLATE="\$WRK_DIR/mibap-\$VERSION"

RELEASE_ARCHIVE=mibap-"$VERSION"_$(uname -m).dmg

# GitHub: https://github.com/dehesselle/mibap
# GitLab: https://gitlab.com/inkscape/devel/mibap
RELEASE_URLS=(
  "https://github.com/dehesselle/mibap/releases/download/\
v$VERSION/$RELEASE_ARCHIVE"
  "https://gitlab.com/api/v4/projects/15865869/packages/generic/mibap/\
$VERSION/$RELEASE_ARCHIVE"
)

### functions ##################################################################

# Nothing here.

### main #######################################################################

# Nothing here.
