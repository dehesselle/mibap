#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later
#
# This file is part of the build pipeline for Inkscape on macOS.
#
# ### uninstall_toolset.sh ###
# Uninstall a previously installed toolset. In this case, "uninstall" means
# "unmount", the downloaded .dmg won't be deleted.

### settings and functions #####################################################

# shellcheck disable=SC1090 # can't point to a single source here
for script in "$(dirname "${BASH_SOURCE[0]}")"/0??-*.sh; do source "$script"; done

error_trace_enable

# shellcheck disable=SC2034 # var is from ansi_.sh
ANSI_TERM_ONLY=false   # use ANSI control characters even if not in terminal

### main #######################################################################

toolset_uninstall
