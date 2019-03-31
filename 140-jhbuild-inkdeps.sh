#!/usr/bin/env bash
# 140-jhbuild-inkdeps.sh
# https://github.com/dehesselle/mibap
#
# Install additional dependencies into our jhbuild environment required for
# building Inkscape.

SELF_DIR=$(cd $(dirname "$0"); pwd -P)
for script in $SELF_DIR/0??-*.sh; do source $script; done

### install GNU Scientific Library #############################################

get_source $URL_GSL
configure_make_makeinstall

### install additional GNOME libraries #########################################

# libsoup - GNOME http client/server library
# adwaita-icon-theme - icons used by Inkscape/GTK

jhbuild build adwaita-icon-theme libsoup

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

### install OpenJPEG ###########################################################

get_source $URL_OPENJPEG
cmake_make_makeinstall

### install Poppler ############################################################

get_source $URL_POPPLER
cmake_make_makeinstall -DENABLE_UNSTABLE_API_ABI_HEADERS=ON

