#!/usr/bin/env bash

### settings
WORK_DIR=/Volumes/WORK
export MAKEFLAGS="-j $(sysctl -n hw.ncpu)"
export HOMEBREW_TEMP=$WORK_DIR/brew.tmp
export BREW_DIR=$WORK_DIR/homebrew
export BREW_EXEC=$BREW_DIR/bin/brew
###


cd $WORK_DIR
#git clone --depth 1 https://gitlab.com/inkscape/inkscape inkscape_master
git clone https://gitlab.com/inkscape/inkscape inkscape_master
cd inkscape_master
git checkout a456169068e7a1ca8715860715fbe912d6cf7fa5  # known to compile!

export LIBPREFIX="$BREW_DIR"
export PATH="$BREW_DIR/bin:$PATH"
export PREFIX=$WORK_DIR/inkscape

brew link --force gettext

mkdir $WORK_DIR/build
cd $WORK_DIR/build
cmake \
-DCMAKE_PREFIX_PATH="$LIBPREFIX" \
-DCMAKE_INSTALL_PREFIX="$PREFIX" \
-DWITH_OPENMP=OFF \
../inkscape_master

make
make install

