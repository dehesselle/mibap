#!/usr/bin/env bash

### settings
WORK_DIR=/Volumes/WORK
export MAKEFLAGS="-j $(sysctl -n hw.ncpu)"
export HOMEBREW_TEMP=$WORK_DIR/brew.tmp
export BREW_DIR=$WORK_DIR/homebrew
export BREW_EXEC=$BREW_DIR/bin/brew
###


cd $WORK_DIR
curl -O https://gitlab.com/inkscape/inkscape/-/archive/INKSCAPE_1_0_ALPHA/inkscape-INKSCAPE_1_0_ALPHA.tar.gz
tar xzf inkscape*.tar.gz
cd inkscape-INKSCAPE_1_0_ALPHA

export LIBPREFIX="$BREW_DIR"
export PATH="$BREW_DIR/bin:$PATH"
export PREFIX=$WORK_DIR/inkscape

brew link --force gettext

# TODO The warning that caused me to include the -Wno-string-compare below
# needs to be investgated later. 
export CXXFLAGS="-Wno-undefined-bool-conversion -Wno-string-compare"

mkdir $WORK_DIR/build
cd $WORK_DIR/build
cmake \
-DCMAKE_PREFIX_PATH="$LIBPREFIX" \
-DCMAKE_INSTALL_PREFIX="$PREFIX" \
-DWITH_OPENMP=OFF \
../inkscape-INKSCAPE_1_0_ALPHA

