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

### settings and functions #####################################################

# shellcheck shell=bash # no shebang as this file is intended to be sourced

# This script gets sourced by every script that needs it. So we only export
# variables if we really need to.
# shellcheck disable=SC2034

# We neither have 'readlink -f' nor 'realpath' on macOS, so we provide our own.
function realpath
{
  local path=$1

  python3 -c "import os; print(os.path.realpath('$path'))"
}

#-- this toolset ---------------------------------------------------------------

TOOLSET_VER=0.47   # main version number; root of our directory layout

# A disk image containing a built version of the whole toolset.
# https://github.com/dehesselle/mibap
TOOLSET_URL=https://github.com/dehesselle/mibap/releases/download/\
v$TOOLSET_VER/mibap_v${TOOLSET_VER}_stripped.dmg

TOOLSET_OVERLAY_SIZE=3   # writable ramdisk overlay, unit in GiB

TOOLSET_REPO_DIR=\$WRK_DIR/repo  # where toolset dmg are downloaded to and kept

#-- target OS version ----------------------------------------------------------

# The recommended build setup as defined in "*_VER_RECOMMENDED" below.

if [ -z "$SDKROOT" ]; then
  SDKROOT=$(xcodebuild -version -sdk macosx Path)
fi
export SDKROOT

SDK_VER=$(/usr/libexec/PlistBuddy -c "Print \
:DefaultProperties:MACOSX_DEPLOYMENT_TARGET" "$SDKROOT"/SDKSettings.plist)
SDK_VER_RECOMMENDED=10.11

XCODE_VER=$(xcodebuild -version | grep Xcode | awk '{ print $2 }')
XCODE_VER_RECOMMENDED=12.3

MACOS_VER=$(sw_vers -productVersion)
MACOS_VER_RECOMMENDED=10.15.7

#-- multithreading -------------------------------------------------------------

MAKEFLAGS="-j $(/usr/sbin/sysctl -n hw.ncpu)"  # use all available cores
export MAKEFLAGS

#-- detect CI ------------------------------------------------------------------

if [ -z "$CI" ]; then   # Both GitHub and GitLab set this.
  CI=false
else
  CI=true   # probably redundant, but for completeness sake
fi

if [ "$CI_PROJECT_NAME" = "inkscape" ]; then
  CI_GITLAB=true
else
  CI_GITLAB=false
fi

#-- directories: self ----------------------------------------------------------

# The fully qualified directory name in canonicalized form.

SELF_DIR=$(dirname "$(realpath "$0")")

#-- directories: work ----------------------------------------------------------

# This is the main directory where all the action takes place below. The
# default, being directly below /Users/Shared, is guaranteed user-writable
# and present on every macOS system.

if [ -z "$WRK_DIR" ]; then
  WRK_DIR=/Users/Shared/work
fi

#-- directories: FSH-like tree below version number ----------------------------

VER_DIR=$WRK_DIR/$TOOLSET_VER
BIN_DIR=$VER_DIR/bin
ETC_DIR=$VER_DIR/etc
INC_DIR=$VER_DIR/include
LIB_DIR=$VER_DIR/lib
VAR_DIR=$VER_DIR/var
BLD_DIR=$VAR_DIR/build
PKG_DIR=$VAR_DIR/cache/pkgs
SRC_DIR=$VER_DIR/usr/src
TMP_DIR=$VER_DIR/tmp

export HOME=$VER_DIR/home   # yes, we redirect the user's home!

#-- directories: temporary locations -------------------------------------------

export TMP=$TMP_DIR
export TEMP=$TMP_DIR
export TMPDIR=$TMP_DIR   # TMPDIR is the common macOS default

#-- directories: XDG -----------------------------------------------------------

export XDG_CACHE_HOME=$VAR_DIR/cache  # instead ~/.cache
export XDG_CONFIG_HOME=$ETC_DIR       # instead ~/.config

#-- directories: pip -----------------------------------------------------------

export PIP_CACHE_DIR=$XDG_CACHE_HOME/pip       # instead ~/Library/Caches/pip
export PIPENV_CACHE_DIR=$XDG_CACHE_HOME/pipenv # instead ~/Library/Caches/pipenv

#-- directories: application bundle layout -------------------------------------

ARTIFACT_DIR=$VER_DIR/artifacts   # parent directory for application bundle

APP_DIR=$ARTIFACT_DIR/Inkscape.app
APP_CON_DIR=$APP_DIR/Contents
APP_RES_DIR=$APP_CON_DIR/Resources
APP_FRA_DIR=$APP_CON_DIR/Frameworks
APP_BIN_DIR=$APP_RES_DIR/bin
APP_ETC_DIR=$APP_RES_DIR/etc
APP_EXE_DIR=$APP_CON_DIR/MacOS
APP_LIB_DIR=$APP_RES_DIR/lib

#-- directories: Inkscape source and build -------------------------------------

if $CI_GITLAB; then   # running GitLab CI
  INK_DIR=$(realpath "$SELF_DIR"/../..)
else                  # not running GitLab CI
  INK_DIR=$SRC_DIR/inkscape

  # Allow using a custom Inkscape repository and branch.
  if [ -z "$INK_URL" ]; then
    INK_URL=https://gitlab.com/inkscape/inkscape
  fi

  # Allow using a custom branch.
  if [ -z "$INK_BRANCH" ]; then
    INK_BRANCH=master
  fi
fi

#-- directories: set path ------------------------------------------------------

export PATH=$BIN_DIR:/usr/bin:/bin:/usr/sbin:/sbin

#-- JHBuild --------------------------------------------------------------------

# configuration files
export JHBUILDRC=$ETC_DIR/jhbuildrc
export JHBUILDRC_CUSTOM=$JHBUILDRC-custom

# JHBuild build system (3.38.0+ from master branch because of specific patch)
# https://gitlab.gnome.org/GNOME/jhbuild
# https://wiki.gnome.org/Projects/Jhbuild/Introduction
JHBUILD_VER=a896cbf404461cab979fa3cd1c83ddf158efe83b
JHBUILD_URL=https://gitlab.gnome.org/GNOME/jhbuild/-/archive/$JHBUILD_VER/\
jhbuild-$JHBUILD_VER.tar.bz2

#-- Python ---------------------------------------------------------------------

# The Python 3 version supplied by the system (technically: Xcode) will be used
# to run JHBuild and Meson, as these two are installed before we build
# Python ourselves. There is no need to use "latest and greatest" here.
PYTHON_SYS_VER=$(python3 -c \
  "import sys; print('{0[0]}.{0[1]}'.format(sys.version_info))")
PYTHON_SYS_VER_RECOMMENDED=3.8

# Inkscape will be bundled with its own (customized) Python 3 runtime to make
# the core extensions work out-of-the-box. This is independent from the
# Python running JHBuild (see PYTHON_SYS_xxx above) and also independent
# from whatever Python version gets built during the various JHBuild steps.
PYTHON_INK_VER_MAJOR=3
PYTHON_INK_VER_MINOR=8
PYTHON_INK_VER_PATCH=5
PYTHON_INK_VER_BUILD=2

PYTHON_INK_VER=$PYTHON_INK_VER_MAJOR.$PYTHON_INK_VER_MINOR  # convenience handle

# https://github.com/dehesselle/py3framework
PYTHON_INK_URL=https://github.com/dehesselle/py3framework/releases/download/\
py${PYTHON_INK_VER/./}$PYTHON_INK_VER_PATCH.$PYTHON_INK_VER_BUILD/\
py${PYTHON_INK_VER/./}${PYTHON_INK_VER_PATCH}_framework_${PYTHON_INK_VER_BUILD}i.tar.xz

#-- Python: packages for Inkscape ----------------------------------------------

# The following Python packages are bundled with Inkscape.

# https://cairocffi.readthedocs.io/en/stable/
# https://github.com/Kozea/cairocffi
PYTHON_CAIROCFFI=cairocffi==1.1.0

# https://lxml.de
# https://github.com/lxml/lxml
# https://github.com/dehesselle/py3framework
PYTHON_LXML=$(dirname $PYTHON_INK_URL)/lxml-4.5.2-\
cp${PYTHON_INK_VER/./}-cp${PYTHON_INK_VER/./}-macosx_10_9_x86_64.whl

# https://github.com/numpy/numpy
PYTHON_NUMPY=numpy==1.19.1

# https://pygobject.readthedocs.io/en/latest/
PYTHON_PYGOBJECT=PyGObject==3.36.1

# https://github.com/scour-project/scour
PYTHON_SCOUR=scour==0.37

# https://pyserial.readthedocs.io/en/latest/
# https://github.com/pyserial/pyserial
PYTHON_PYSERIAL=pyserial==3.4

#-- Python: auxiliary packages -------------------------------------------------

# The following Python packages are required for the build system.

# convert SVG to PNG
# https://cairosvg.org
PYTHON_CAIROSVG=cairosvg==2.4.2

# Mozilla Root Certificates
# https://pypi.org/project/certifi
PYTHON_CERTIFI=certifi   # This is unversioned on purpose.

# create disk image (incl. dependencies)
# https://dmgbuild.readthedocs.io/en/latest/
# https://github.com/al45tair/dmgbuild
# dependencies:
# - biplist: binary plist parser/generator
# - pyobjc-*: framework wrappers; pinned to 6.2.2 as 7.0 includes fixes for
#   Big Sur (dyld cache) that break on Catalina
PYTHON_DMGBUILD="\
  biplist==1.0.3\
  pyobjc-core==6.2.2\
  pyobjc-framework-Cocoa==6.2.2\
  pyobjc-framework-Quartz==6.2.2\
  dmgbuild==1.4.2\
"

# Meson build system
# https://mesonbuild.com
PYTHON_MESON=meson==0.55.1

#-- auxiliary software ---------------------------------------------------------

# Every required piece of software for building, packaging etc. that doesn't
# have its own section ends up here.

# Ninja build system
# https://github.com/ninja-build/ninja
NINJA_VER=1.8.2
NINJA_URL=https://github.com/ninja-build/ninja/releases/download/v$NINJA_VER/\
ninja-mac.zip

# convert PNG image to iconset in ICNS format
# https://github.com/bitboss-ca/png2icns
PNG2ICNS_VER=0.1
PNG2ICNS_URL=https://github.com/bitboss-ca/png2icns/archive/\
v$PNG2ICNS_VER.tar.gz

#-- deferred expansion ---------------------------------------------------------

# To keep order in the sections above, some variables need deferred expansion.

TOOLSET_REPO_DIR=$(eval echo $TOOLSET_REPO_DIR)
