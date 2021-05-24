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

#--------------------------------------------------------- run time dependencies

# Build Python wheels and save them to our package cache.

jhbuild run pip3 install wheel
jhbuild run pip3 wheel "$INK_PYTHON_CSSSELECT" -w "$PKG_DIR"
jhbuild run pip3 wheel "$INK_PYTHON_LXML"      -w "$PKG_DIR"
jhbuild run pip3 wheel "$INK_PYTHON_NUMPY"     -w "$PKG_DIR"
jhbuild run pip3 wheel "$INK_PYTHON_PYGOBJECT" -w "$PKG_DIR"
jhbuild run pip3 wheel "$INK_PYTHON_PYSERIAL"  -w "$PKG_DIR"
jhbuild run pip3 wheel "$INK_PYTHON_SCOUR"     -w "$PKG_DIR"
