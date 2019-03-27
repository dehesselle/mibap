#!/usr/bin/env bash
# 060-jhbuild-inkdeps.sh
# https://github.com/dehesselle/mibap
#
# Install additional dependencies into our jhbuild environment required for
# building Inkscape.

SELF_DIR=$(cd $(dirname "$0"); pwd -P)
source $SELF_DIR/010-vars.sh
source $SELF_DIR/020-funcs.sh

### install GNU Scientific Library #############################################

get_source $URL_GSL
configure_make_makeinstall

### install additional GNOME libraries http client/server library ##############

# libsoup - GNOME http client/server library
# vala - compiler using GObject Type System

jhbuild build libsoup vala

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

