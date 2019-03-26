# 010-vars.sh
# https://github.com/dehesselle/mibap
#
# This file contains all the global variables and is meant to be sourced by 
# other files.

[ -z $VARS_INCLUDED ] && VARS_INCLUDED=true || return   # include guard

#### compilation settings ######################################################

CORES=$(sysctl -n hw.ncpu)   # use all available cores
export MAKEFLAGS="-j $CORES"

### workspace/build environment paths ##########################################

RAMDISK=WORK   # name of ramdisk
RAMDISK_SIZE=8   # unit is GiB
WRK_DIR=/Volumes/$RAMDISK   # path to ramdisk
OPT_DIR=$WRK_DIR/opt
BIN_DIR=$OPT_DIR/bin
TMP_DIR=$OPT_DIR/tmp
SRC_DIR=$OPT_DIR/src
LIB_DIR=$OPT_DIR/lib

### application bundle paths ###################################################

APP_DIR=$HOME/Desktop/Inkscape.app   # if you want to change this, also change
                                     #   - inkscape.bundle
                                     #   - inkscape.plist
APP_RES_DIR=$APP_DIR/Contents/Resources
APP_LIB_DIR=$APP_RES_DIR/lib
APP_BIN_DIR=$APP_RES_DIR/bin
APP_EXE_DIR=$APP_DIR/Contents/MacOS
APP_PLIST=$APP_DIR/Contents/Info.plist

### downlad URLs ###############################################################

URL_BOOST=https://dl.bintray.com/boostorg/release/1.69.0/source/boost_1_69_0.tar.bz2
URL_FREETYPE=https://download.savannah.gnu.org/releases/freetype/freetype-2.10.0.tar.bz2
URL_GC=http://www.hboehm.info/gc/gc_source/gc-8.0.2.tar.gz
URL_GDL=https://github.com/GNOME/gdl/archive/GDL_3_28_0.tar.gz
URL_GLIBMM=https://github.com/GNOME/glibmm/archive/2.56.1.tar.gz
URL_GSL=http://ftp.fau.de/gnu/gsl/gsl-2.5.tar.gz
URL_GTK_OSX_BUILD_SETUP=https://gitlab.gnome.org/GNOME/gtk-osx/raw/master/gtk-osx-build-setup.sh
URL_LIBPSL=https://github.com/rockdaboot/libpsl/releases/download/libpsl-0.20.2/libpsl-0.20.2.tar.gz
URL_LIBSOUP=https://ftp.gnome.org/pub/GNOME/sources/libsoup/2.65/libsoup-2.65.92.tar.xz
URL_OPENJPEG=https://github.com/uclouvain/openjpeg/archive/v2.3.0.tar.gz
URL_OPENSSL=https://www.openssl.org/source/openssl-1.1.1b.tar.gz
URL_POPPLER=https://gitlab.freedesktop.org/poppler/poppler/-/archive/poppler-0.74.0/poppler-poppler-0.74.0.tar.gz
# Inkscape Git
URL_INKSCAPE=https://gitlab.com/inkscape/inkscape
