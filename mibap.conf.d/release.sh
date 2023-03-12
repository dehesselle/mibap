# SPDX-FileCopyrightText: 2023 René de Hesselle <dehesselle@web.de>
#
# SPDX-License-Identifier: GPL-2.0-or-later

### description ################################################################

# Custom naming requires a custom release archive name. And since we produce
# custom releases, the URLs have to be changed as well.

### shellcheck #################################################################

# shellcheck shell=bash # no shebang as this file is intended to be sourced
# shellcheck disable=SC2034 # we only use exports if we really need them

### variables ##################################################################

RELEASE_ARCHIVE=mibap-"$VERSION"_$(uname -m).dmg

# GitLab: https://gitlab.com/inkscape/devel/mibap
# GitHub: https://github.com/dehesselle/mibap
RELEASE_URLS=(
  "https://gitlab.com/api/v4/projects/15865869/packages/generic/mibap/\
v$VERSION/$RELEASE_ARCHIVE"
  "https://github.com/dehesselle/mibap/releases/download/\
v$VERSION/$RELEASE_ARCHIVE"
)

### functions ##################################################################

# Nothing here.

### main #######################################################################

# Nothing here.
