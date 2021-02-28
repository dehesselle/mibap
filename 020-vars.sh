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

#-- the main version number ----------------------------------------------------

VERSION=0.47

#-- target OS version ----------------------------------------------------------

# The recommended build setup as defined in "*_VER_RECOMMENDED" below.

if [ -z "$SDKROOT" ]; then
  SDKROOT=$(xcodebuild -version -sdk macosx Path)
fi
export SDKROOT

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
# We neither have 'readlink -f' nor 'realpath' on macOS, so we use Python.
SELF_DIR=$(dirname "$(python3 -c "import os; print(os.path.realpath('$0'))")")

#-- directories: work ----------------------------------------------------------

# This is the main directory where all the action takes place below. The
# default, being directly below /Users/Shared, is guaranteed user-writable
# and present on every macOS system.

if [ -z "$WRK_DIR" ]; then
  WRK_DIR=/Users/Shared/work
fi

#-- directories: FSH-like tree below version number ----------------------------

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

#-- directories: artifact ------------------------------------------------------

ARTIFACT_DIR=$VER_DIR/artifacts   # parent directory for application bundle

#-- set path -------------------------------------------------------------------

export PATH=$BIN_DIR:/usr/bin:/bin:/usr/sbin:/sbin
