# SPDX-License-Identifier: GPL-2.0-or-later
# This file is part of the build pipeline for Inkscape on macOS.

### description ################################################################

# This is the main initialization file to setup the environment. Its purpose is
#   - to provide some basic configuration in its variables section
#     which do not fit into any package (see files in packages directory)
#     and/or all the other files depend upon
#   - source all other scripts
#   - run a few essential checks to see if we're good
#
# It's also supposed to be a "passive" file, i.e. it defines variables and
# functions but does not do anything on its own. However, this is only
# 99% true at the moment as the above mentioned checks are capable of
# calling it quits if a few very fundamental things appear to be broken.

### settings ###################################################################

# shellcheck shell=bash # no shebang as this file is intended to be sourced
# shellcheck disable=SC2034 # we only use export if we really need it

### variables ##################################################################

#----------------------------------------------------------------------- version

VERSION=0.47

#-------------------------------------------------------------- target OS by SDK

if [ -z "$SDKROOT" ]; then
  SDKROOT=$(xcodebuild -version -sdk macosx Path)
fi
export SDKROOT

#-------------------------------------------------------- max. simultaneous jobs

MAKEFLAGS="-j $(/usr/sbin/sysctl -n hw.ncpu)"  # use all available cores
export MAKEFLAGS

#--------------------------------------------------------------------- detect CI

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

#------------------------------------------------------------- directories: self

# The fully qualified directory name in canonicalized form.
# We neither have 'readlink -f' nor 'realpath' on macOS, so we use Python.
SELF_DIR=$(dirname \
  "$(python3 -c "import os; print(os.path.realpath('${BASH_SOURCE[0]}'))")")

#------------------------------------------------------------- directories: work

# This is the main directory where all the action takes place below. The
# default, being directly below /Users/Shared, is guaranteed user-writable
# and present on every macOS system.

if [ -z "$WRK_DIR" ]; then
  WRK_DIR=/Users/Shared/work
fi

#---------------------------- directories: FSH-like layout for the build toolset

VER_DIR=$WRK_DIR/$VERSION
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

#---------------------------------------------- directories: temporary locations

export TMP=$TMP_DIR
export TEMP=$TMP_DIR
export TMPDIR=$TMP_DIR   # TMPDIR is the common macOS default

#-------------------------------------------------------------- directories: XDG

export XDG_CACHE_HOME=$VAR_DIR/cache  # instead ~/.cache
export XDG_CONFIG_HOME=$ETC_DIR       # instead ~/.config

#-------------------------------------------------------------- directories: pip

export PIP_CACHE_DIR=$XDG_CACHE_HOME/pip       # instead ~/Library/Caches/pip
export PIPENV_CACHE_DIR=$XDG_CACHE_HOME/pipenv # instead ~/Library/Caches/pipenv

#--------------------------------------------------------- directories: artifact

ARTIFACT_DIR=$VER_DIR/artifacts   # parent directory for build artifacts

#---------------------------------------------------------------------- set path

export PATH=$BIN_DIR:/usr/bin:/bin:/usr/sbin:/sbin

### functions ##################################################################

# Nothing here.

### main #######################################################################

#------------------------------------------ source functions from bash_d library

# https://github.com/dehesselle/bash_d

INCLUDE_DIR=$SELF_DIR/bash_d
# shellcheck source=bash_d/1_include_.sh
source "$INCLUDE_DIR"/1_include_.sh
include_file echo_.sh
include_file error_.sh
include_file lib_.sh
include_file sed.sh

#----------------------------------------------------------- source our packages

for package in "$SELF_DIR"/packages/*.sh; do
  # shellcheck disable=SC1090 # can't point to a single source here
  source "$package"
done

#---------------------------------------------------- check if WRK_DIR is usable

# shellcheck disable=SC2046 # result is integer
if  [ $(mkdir -p "$WRK_DIR" 2>/dev/null; echo $?) -eq 0 ] &&
    [ -w "$WRK_DIR" ] ; then
  : # WRK_DIR has been created or was already there and is writable
else
  echo_e "WRK_DIR not usable: $WRK_DIR"
  exit 1
fi

#----------------------------------------------------- check for presence of SDK

if [ ! -d "$SDKROOT" ]; then
  echo_e "SDK not found: $SDKROOT"
  exit 1
fi

#---------------------------------------------------- check recommended versions

sys_check_ver
