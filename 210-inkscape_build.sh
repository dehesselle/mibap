#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later
#
# This file is part of the build pipeline for Inkscape on macOS.
#
# ### 210-inkscape_build.sh ###
# Build Inscape.

### settings and functions #####################################################

# shellcheck disable=SC1090 # can't point to a single source here
for script in "$(dirname "${BASH_SOURCE[0]}")"/0??-*.sh; do source "$script"; done

include_file ansi_.sh
include_file error_.sh
error_trace_enable

# shellcheck disable=SC2034 # var is from ansi_.sh
ANSI_TERM_ONLY=false   # use ANSI control characters even if not in terminal

### variables ##################################################################

INK_BLD_DIR=$BLD_DIR/$(basename "$INK_DIR")

#-- configure ccache -----------------------------------------------------------

ccache_configure  # create directory and config file

#-- configure JHBuild ----------------------------------------------------------

# This allows compiling Inkscape with a different setup than the toolset.

configure_jhbuild

#-- build Inkscape -------------------------------------------------------------

if ! $CI_GITLAB; then     # not running GitLab CI

  if [ -d "$INK_DIR"/.git ]; then   # Already cloned?
    # Special treatment 1/2 for local builds: Leave it up to the
    # user if they need a fresh clone. This way we enable makeing changes
    # to the code and running the build again.
    echo_w "using existing repository in $INK_DIR"
    echo_w "Do 'rm -rf $INK_DIR' if you want a fresh clone."
    sleep 5
  else
    git clone \
      --branch "$INK_BRANCH" \
      --depth 10 \
      --recurse-submodules \
      --single-branch \
      "$INK_URL" "$INK_DIR"
  fi

  if ! $CI && [ -d "$INK_BLD_DIR" ]; then   # Running locally and build exists?
    # Special treatment 2/2 for local builds: remove the build directory
    # to ensure clean builds.
    rm -rf "$INK_BLD_DIR"
  fi
fi

mkdir -p "$INK_BLD_DIR"
# shellcheck disable=SC2164 # we have error trapping
cd "$INK_BLD_DIR"

cmake \
  -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
  -DCMAKE_PREFIX_PATH="$VER_DIR" \
  -DCMAKE_INSTALL_PREFIX="$VER_DIR" \
  "$INK_DIR"

make
make install
make tests

#-- patch Poppler library locations --------------------------------------------

lib_change_path \
  "$LIB_DIR"/libpoppler\\..+dylib \
  "$BIN_DIR"/inkscape \
  "$LIB_DIR"/inkscape/libinkscape_base.dylib

lib_change_path \
  "$LIB_DIR"/libpoppler-glib\\..+dylib \
  "$BIN_DIR"/inkscape \
  "$LIB_DIR"/inkscape/libinkscape_base.dylib

#-- patch OpenMP library locations ---------------------------------------------

lib_change_path \
  "$LIB_DIR"/libomp.dylib \
  "$BIN_DIR"/inkscape \
  "$LIB_DIR"/inkscape/libinkscape_base.dylib
