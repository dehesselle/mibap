# SPDX-FileCopyrightText: 2023 René de Hesselle <dehesselle@web.de>
#
# SPDX-License-Identifier: GPL-2.0-or-later

### description ################################################################

# Set the supported macOS versions.

### shellcheck #################################################################

# shellcheck shell=bash # no shebang as this file is intended to be sourced
# shellcheck disable=SC2034 # we only use exports if we really need them

### dependencies ###############################################################

# Nothing here.

### variables ##################################################################

# mibap is built exclusively on Monterey
SYS_MACOS_VER_SUPPORTED=(
  12.6.3
  12.6.2
  12.6.1
  12.6
)

### functions ##################################################################

# Nothing here.

### main #######################################################################

# Nothing here.
