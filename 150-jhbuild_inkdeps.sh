#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: 2021 René de Hesselle <dehesselle@web.de>
#
# SPDX-License-Identifier: GPL-2.0-or-later

### description ################################################################

# Install Inkscape dependencies.

### includes ###################################################################

# shellcheck disable=SC1090 # can't point to a single source here
for script in "$(dirname "${BASH_SOURCE[0]}")"/0??-*.sh; do
  source "$script";
done

### settings ###################################################################

# Nothing here.

### main #######################################################################

#------------------------------------------------------- build time dependencies

jhbuild build \
  bdwgc \
  doubleconversion \
  googletest \
  gsl \
  gspell \
  imagemagick \
  libcdr \
  libsoup \
  libvisio \
  openjpeg \
  openmp \
  poppler \
  potrace

#------------------------------------------------- run time dependencies: Python

# Download custom Python runtime.

ink_download_python

# Build Python wheels and save them to our package cache.

ink_build_wheels

# To provide backward compatibility, wheels are also built externally on a
# machine running the minimum supported OS version. Download those to our
# package cache as well. (This does not overwrite the above ones.)

ink_download_wheels
