#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: 2021 René de Hesselle <dehesselle@web.de>
#
# SPDX-License-Identifier: GPL-2.0-or-later

### description ################################################################

# Build and install Inkscape. For non-CI builds, this will build Inkscape
# master branch. Installation prefix is VER_DIR.

### shellcheck #################################################################

# Nothing here.

### dependencies ###############################################################

source "$(dirname "${BASH_SOURCE[0]}")"/jhb/etc/jhb.conf.sh
source "$(dirname "${BASH_SOURCE[0]}")"/src/ink.sh

bash_d_include error
bash_d_include lib

### variables ##################################################################

# Nothing here.

### functions ##################################################################

# Nothing here.

### main #######################################################################

error_trace_enable

#----------------------------------------------------------- (re-) configure jhb

# Rerun configuration to adapt to the current system. This will
#   - allow Inkscape to be build against a different SDK than the toolset has
#     been built with
#   - setup ccache

jhb configure

#---------------------------------------------------------------- build Inkscape

if ! $CI_GITLAB; then     # not running GitLab CI

  if [ -d "$INK_DIR" ]; then   # Sourcecode directory already there?
    echo_i "using existing source $INK_DIR"
  else
    git clone \
      --branch "$INK_BRANCH" \
      --depth 10 \
      --recurse-submodules \
      --single-branch \
      "$INK_URL" "$INK_DIR"
  fi

  # Remove files from a previous build if they exist. This is to ensure clean
  # builds when running locally or on non-ephemeral runners.
  if [ -d "$INK_BLD_DIR" ]; then
    rm -rf "$INK_BLD_DIR"
  fi
fi

mkdir -p "$INK_BLD_DIR"
cd "$INK_BLD_DIR" || exit 1

cmake \
  -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
  -DCMAKE_C_COMPILER_LAUNCHER=ccache \
  -DCMAKE_PREFIX_PATH="$VER_DIR" \
  -DCMAKE_INSTALL_PREFIX="$VER_DIR" \
  -GNinja \
  "$INK_DIR"

ninja
ninja install

#----------------------------------- make libraries work for unpackaged Inkscape

# Most libraries are linked to with their fully qualified paths, a few have been
# linked to using '@rpath'. The Inkscape binary only provides an LC_RPATH
# setting for its custom library path 'lib/inkscape' at this point, so we need
# to add the common library path 'lib'.

lib_add_rpath @loader_path/../lib "$BIN_DIR"/inkscape
