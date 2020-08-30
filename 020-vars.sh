# SPDX-License-Identifier: GPL-2.0-or-later
#
# This file is part of the build pipeline for Inkscape on macOS.
#
# ### 020-vars.sh ###
# This file contains all the global variables (as in: configuration for the
# build pipeline) and gets sourced by all the other scripts.
# If you want to override settings, the suggested way is that you create a
# `0nn-custom.sh` file and put them there. All files named '0nn-*.sh' get
# sourced in numerical order.

[ -z $VARS_INCLUDED ] && VARS_INCLUDED=true || return   # include guard

### name and directory #########################################################

SELF_NAME=$(basename $0)

### multithreading #############################################################

CORES=$(sysctl -n hw.ncpu)   # use all available cores
export MAKEFLAGS="-j $CORES"

### target OS version ##########################################################

# The current build setup is
#   - Xcode 11.6
#   - OS X El Capitan 10.11 SDK (part of Xcode 7.3.1)
#   - macOS Catalina 10.15.6

export MACOSX_DEPLOYMENT_TARGET=10.11
[ -z $SDKROOT_DIR ] && SDKROOT_DIR=/opt/sdks
export SDKROOT=$SDKROOT_DIR/MacOSX${MACOSX_DEPLOYMENT_TARGET}.sdk

### build system/toolset version ###############################################

TOOLSET_VERSION=0.39

### ramdisk ####################################################################

# Using the toolset dmg, a small writable overlay is required.
OVERLAY_RAMDISK_SIZE=3   # unit is GiB

### main work directory ########################################################

# This is the main directory where all the action takes place below.

# Allow this to be overridable or use the default.
[ -z $WRK_DIR ] && WRK_DIR=/Users/Shared/work || true

if  [ $(mkdir -p $WRK_DIR 2>/dev/null; echo $?) -eq 0 ] &&
    [ -w $WRK_DIR ] ; then
  :   # nothing to do, everything ok
else
  echo "***ERROR*** WRK_DIR not usable: $WRK_DIR"
  exit 1
fi

### toolset directories ########################################################

# This is where .dmg files with pre-compiled toolsets are downloaded to.
REPO_DIR=$WRK_DIR/repo
# Persistent location for ccache.
export CCACHE_DIR=$WRK_DIR/ccache
# Directory with ccache binaries.
export CCACHE_BIN_DIR=/opt/ccache/bin

### work directory and subdirectories ##########################################

# Allow this to be overrideable or use version number as default.
[ -z $VER_DIR ] && VER_DIR=$WRK_DIR/$TOOLSET_VERSION || true

BIN_DIR=$VER_DIR/bin
ETC_DIR=$VER_DIR/etc
LIB_DIR=$VER_DIR/lib
VAR_DIR=$VER_DIR/var
PKG_DIR=$VAR_DIR/cache/pkgs
SRC_DIR=$VER_DIR/usr/src
TMP_DIR=$VER_DIR/tmp

### use TMP_DIR for everything temporary #######################################

export TMP=$TMP_DIR
export TEMP=$TMP_DIR
export TMPDIR=$TMP_DIR                # TMPDIR is the common macOS default

### XDG ########################################################################

export XDG_CACHE_HOME=$VER_DIR/var/cache  # instead ~/.cache
export XDG_CONFIG_HOME=$ETC_DIR           # instead ~/.config

### pip ########################################################################

export PIP_CACHE_DIR=$XDG_CACHE_HOME/pip         # instead ~/Library/Caches/pip
export PIPENV_CACHE_DIR=$XDG_CACHE_HOME/pipenv   # instead ~/Library/Caches/pipenv

# TODO: ~/Library/Caches/pip-tools ?

### JHBuild configuration ######################################################

export JHBUILDRC=$ETC_DIR/jhbuildrc
export JHBUILDRC_CUSTOM=$JHBUILDRC-custom

JHBUILD_BUILDROOT=$VAR_DIR/build

### Inkscape Git repository directory ##########################################

# Location is different when running as GitLab CI job.

if [ -z $CI_JOB_ID ]; then
  INK_DIR=$SRC_DIR/inkscape
else
  INK_DIR=$SELF_DIR/../..   # SELF_DIR needs to be set by the sourcing script
  INK_DIR=$(cd $INK_DIR; pwd -P)   # make path canoncial
fi

### artifact path ##############################################################

# This is the location where the final product - like application bundle or
# diskimage (no intermediate programs/libraries/...) - is created in.

ARTIFACT_DIR=$VER_DIR/artifacts

### application bundle paths ###################################################

APP_DIR=$ARTIFACT_DIR/Inkscape.app
APP_CON_DIR=$APP_DIR/Contents
APP_RES_DIR=$APP_CON_DIR/Resources
APP_FRA_DIR=$APP_CON_DIR/Frameworks
APP_BIN_DIR=$APP_RES_DIR/bin
APP_ETC_DIR=$APP_RES_DIR/etc
APP_EXE_DIR=$APP_CON_DIR/MacOS
APP_LIB_DIR=$APP_RES_DIR/lib

APP_PLIST=$APP_CON_DIR/Info.plist

### bundled Python version #####################################################

PY3_MAJOR=3
PY3_MINOR=8
PY3_PATCH=5
PY3_BUILD=1  # custom framework build number

### download URLs for dependencies #############################################

# https://github.com/dehesselle/gtk-osx
# Forked from https://gitlab.gnome.org/GNOME/gtk-osx
URL_GTK_OSX=https://raw.githubusercontent.com/dehesselle/gtk-osx/inkscape-1.1.x-2
URL_GTK_OSX_MODULESET=$URL_GTK_OSX/modulesets-stable/inkscape.modules

### download URLs for auxiliary software #######################################

# These are versioned URLs of software that is not a direct dependency but
# required for building, packaging or similar.

# create application bundle
# https://github.com/dehesselle/gtk-mac-bundler
# Forked from https://gitlab.gnome.org/GNOME/gtk-mac-bundler
URL_GTK_MAC_BUNDLER=https://github.com/dehesselle/gtk-mac-bundler/archive/f96a9daf2236814af7ace7a2fa91bbfb4f077779.tar.gz
# Inkscapge Git repo (for standalone/non-CI builds)
URL_INKSCAPE=https://gitlab.com/inkscape/inkscape
# disk image icon
URL_INKSCAPE_DMG_ICNS=https://github.com/dehesselle/mibap/raw/master/inkscape_dmg.icns
# JHBuild build system
# https://gitlab.gnome.org/GNOME/jhbuild
# https://wiki.gnome.org/Projects/Jhbuild/Introduction
URL_JHBUILD=https://gitlab.gnome.org/GNOME/jhbuild/-/archive/3.36.0/jhbuild-3.36.0.tar.gz
# Ninja build system
# https://github.com/ninja-build/ninja
URL_NINJA=https://github.com/ninja-build/ninja/releases/download/v1.8.2/ninja-mac.zip
# convert PNG image to iconset in ICNS format
# https://github.com/bitboss-ca/png2icns
URL_PNG2ICNS=https://github.com/bitboss-ca/png2icns/archive/v0.1.tar.gz
# This is a relocatable Python.framework to be bundled with the app.
# https://github.com/dehesselle/py3framework
URL_PYTHON=https://github.com/dehesselle/py3framework/releases/download/py$PY3_MAJOR$PY3_MINOR$PY3_PATCH.$PY3_BUILD/py$PY3_MAJOR$PY3_MINOR${PY3_PATCH}_framework_$PY3_BUILD.tar.xz
# A pre-compiled version of the whole toolset.
# https://github.com/dehesselle/mibap
URL_TOOLSET=https://github.com/dehesselle/mibap/releases/download/v$TOOLSET_VERSION/mibap_v$TOOLSET_VERSION.dmg

### Python: packages for Inkscape ##############################################

# The following Python packages are bundled with Inkscape.

# https://cairocffi.readthedocs.io/en/stable/
# https://github.com/Kozea/cairocffi
PYTHON_CAIROCFFI=cairocffi==1.1.0
# https://lxml.de
# https://github.com/lxml/lxml
PYTHON_LXML_SRC=https://lxml.de/files/lxml-4.5.2.tgz
PYTHON_LXML=$PKG_DIR/$(basename -s .tgz $PYTHON_LXML_SRC)-cp$PY3_MAJOR$PY3_MINOR-cp$PY3_MAJOR$PY3_MINOR-macosx_${MACOSX_DEPLOYMENT_TARGET/./_}_x86_64.whl
# https://github.com/numpy/numpy
PYTHON_NUMPY=numpy==1.19.1
# https://pygobject.readthedocs.io/en/latest/
PYTHON_PYGOBJECT=PyGObject==3.36.1
# https://github.com/scour-project/scour
PYTHON_SCOUR=scour==0.37
# https://pyserial.readthedocs.io/en/latest/
# https://github.com/pyserial/pyserial
PYTHON_PYSERIAL=pyserial==3.4

### Python: auxiliary packages #################################################

# convert SVG to PNG
# https://cairosvg.org
PYTHON_CAIROSVG=cairosvg==2.4.2
# create DMG
# https://dmgbuild.readthedocs.io/en/latest/
# https://github.com/al45tair/dmgbuild
PYTHON_DMGBUILD=dmgbuild==1.3.3
# Meson build system
# https://mesonbuild.com
PYTHON_MESON=meson==0.55.1

### path #######################################################################

export PATH=$BIN_DIR:/usr/bin:/bin:/usr/sbin:/sbin
