#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later
# This file is part of the build pipeline for Inkscape on macOS.

### description ################################################################

# In order to make JHBuild usable to build software, it needs to be bootstrapped
# first. Also Meson and Ninja are have to installed as external dependencies.

### includes ###################################################################

# shellcheck disable=SC1090 # can't point to a single source here
for script in "$(dirname "${BASH_SOURCE[0]}")"/0??-*.sh; do
  source "$script";
done

### settings ###################################################################

# Nothing here.

### main #######################################################################

#------------------------------------------------------------- bootstrap JHBuild

mkdir -p "$XDG_CACHE_HOME"

# Basic bootstrapping.
jhbuild bootstrap-gtk-osx

#----------------------------------------------------------------- install Meson

meson_install

#----------------------------------------------------------------- install Ninja

ninja_install