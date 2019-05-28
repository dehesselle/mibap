#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later
#
# This file is part of the build pipeline for Inkscape on macOS.
#
# ### 150-jhbuild-inkdeps.sh ###
# Install additional dependencies into our jhbuild environment required for
# building Inkscape.

### load settings and functions ################################################

SELF_DIR=$(cd $(dirname "$0"); pwd -P)
for script in $SELF_DIR/0??-*.sh; do source $script; done

### install additional GNOME libraries #########################################

# adwaita-icon-theme - icons used by Inkscape/GTK
# gtkspell3 - GtkSpell spellchecking/highlighting
# libsoup - GNOME http client/server library

jhbuild build \
  adwaita-icon-theme \
  gtkspell3 \
  libsoup

### install GNU Scientific Library #############################################

get_source $URL_GSL
configure_make_makeinstall

### install Garbage Collector for C/C++ ########################################

get_source $URL_GC
configure_make_makeinstall

### install GNOME Docking Library ##############################################

get_source $URL_GDL
jhbuild run ./autogen.sh
configure_make_makeinstall

### install boost ##############################################################

get_source $URL_BOOST
jhbuild run ./bootstrap.sh --prefix=$OPT_DIR
jhbuild run ./b2 -j$CORES install

### install little CMS colore engine v2 ########################################

get_source $URL_LCMS2
configure_make_makeinstall

### install OpenJPEG ###########################################################

get_source $URL_OPENJPEG
cmake_make_makeinstall

### install libyaml ############################################################

get_source $URL_LIBYAML
cmake_make_makeinstall -DBUILD_SHARED_LIBS=ON

### install CppUnit ############################################################

# required by librevenge

get_source $URL_CPPUNIT
configure_make_makeinstall

### install librevenge #########################################################

# required by libcdr

get_source $URL_LIBREVENGE
configure_make_makeinstall

### install libcdr #############################################################

get_source $URL_LIBCDR
jhbuild run ./autogen.sh
configure_make_makeinstall

### install ImageMagick 6 ######################################################

get_source $URL_IMAGEMAGICK
configure_make_makeinstall

### install Poppler ############################################################

get_source $URL_POPPLER
cmake_make_makeinstall -DENABLE_UNSTABLE_API_ABI_HEADERS=ON

### install gtk-mac-bundler ####################################################

get_source $URL_GTK_MAC_BUNDLER
make install

### install double-conversion ##################################################

# Required by lib2geom.

get_source $URL_DOUBLE_CONVERSION
cmake_make_makeinstall

### install Potrace ############################################################

get_source $URL_POTRACE
configure_make_makeinstall --with-libpotrace

### install OpenMP #############################################################

get_source $URL_OPENMP
cmake_make_makeinstall

