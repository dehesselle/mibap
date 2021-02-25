# SPDX-License-Identifier: GPL-2.0-or-later
#
# This file is part of the build pipeline for Inkscape on macOS.
#
# ### 040-pkgs.sh ###
# Source all the packages.

### settings and functions #####################################################

# shellcheck shell=bash # no shebang as this file is intended to be sourced

#-- source packages ------------------------------------------------------------

for pkg in "$SELF_DIR"/pkgs/*.sh; do
  # shellcheck disable=SC1090 # can't point to a single source here
  source "$pkg"
done
