#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later
#
# This file is part of the build pipeline for Inkscape on macOS.
#
# ### jhbshell.sh ###
# Start a JHBuild shell.
# Since we have a customized JHBuild environment with lots of settings, this
# takes care of that.

### settings and functions #####################################################

# shellcheck disable=SC1090 # can't point to a single source here
for script in "$(dirname "${BASH_SOURCE[0]}")"/0??-*.sh; do source "$script"; done

### main #######################################################################

jhbuild shell
