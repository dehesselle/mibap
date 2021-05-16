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
