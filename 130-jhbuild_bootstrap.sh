#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later
#
# This file is part of the build pipeline for Inkscape on macOS.
#
# ### 130-jhbuild_bootstrap.sh ###
# Bootstrap the JHBuild environment.

### settings and functions #####################################################

# shellcheck disable=SC1090 # can't point to a single source here
for script in "$(dirname "${BASH_SOURCE[0]}")"/0??-*.sh; do source "$script"; done

#-- bootstrap JHBuild ----------------------------------------------------------

mkdir -p "$PKG_DIR" "$XDG_CACHE_HOME"

# Basic bootstrapping.
jhbuild bootstrap-gtk-osx

# Install Meson build system.
meson_install

# Install Ninja build system.
ninja_install