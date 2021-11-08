# SPDX-FileCopyrightText: 2021 René de Hesselle <dehesselle@web.de>
#
# SPDX-License-Identifier: GPL-2.0-or-later

### description ################################################################

# Using ccache greatly reduces build times.

### shellcheck #################################################################

# shellcheck shell=bash # no shebang as this file is intended to be sourced

### dependencies ###############################################################

# Nothing here.

### variables ##################################################################

export CCACHE_DIR=${CCACHE_DIR:-$WRK_DIR/ccache}

# https://ccache.dev
# https://github.com/ccache/ccache
# https://github.com/dehesselle/ccache_macos
CCACHE_VER=4.4.2r1
CCACHE_URL=https://github.com/dehesselle/ccache_macos/releases/download/\
v$CCACHE_VER/ccache_v$CCACHE_VER.tar.xz

### functions ##################################################################

function ccache_configure
{
    mkdir -p "$CCACHE_DIR"

  cat <<EOF > "$CCACHE_DIR/ccache.conf"
base_dir = $WRK_DIR
hash_dir = false
max_size = 3.0G
temporary_dir = $CCACHE_DIR/tmp
EOF
}

function ccache_install
{
  curl -L $CCACHE_URL | tar -C "$BIN_DIR" --exclude="ccache.sha256" -xJ

  for compiler in clang clang++ gcc g++; do
    ln -s ccache "$BIN_DIR"/$compiler
  done
}

### main #######################################################################

# Nothing here.