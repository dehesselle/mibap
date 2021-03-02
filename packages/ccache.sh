# SPDX-License-Identifier: GPL-2.0-or-later

### settings ###################################################################

# shellcheck shell=bash # no shebang as this file is intended to be sourced
# shellcheck disable=SC2034 # globally defined variables here w/o export

### description ################################################################

# This file contains everything related to setup ccache.

### variables ##################################################################

if [ -z "$CCACHE_DIR" ]; then
  CCACHE_DIR=$WRK_DIR/ccache
fi
export CCACHE_DIR
CCACHE_SIZE=3.0G

# https://ccache.dev
# https://github.com/ccache/ccache
CCACHE_VER=3.7.12
CCACHE_URL=https://github.com/ccache/ccache/releases/download/\
v$CCACHE_VER/ccache-$CCACHE_VER.tar.xz

### functions ##################################################################

function ccache_configure
{
  mkdir -p "$CCACHE_DIR"

  cat <<EOF > "$CCACHE_DIR/ccache.conf"
max_size = $CCACHE_SIZE
hash_dir = false
EOF
}

function ccache_install
{
  local archive
  archive=$PKG_DIR/$(basename $CCACHE_URL)
  curl -o "$archive" -L "$CCACHE_URL"
  tar -C "$SRC_DIR" -xf "$archive"
  # shellcheck disable=SC2164 # we trap errors to catch bad 'cd'
  cd "$SRC_DIR"/ccache-$CCACHE_VER

  ./configure --prefix="$VER_DIR"
  make
  make install

  for compiler in clang clang++ gcc g++; do
    ln -s ccache "$BIN_DIR"/$compiler
  done
}