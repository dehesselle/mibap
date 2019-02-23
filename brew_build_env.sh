#!/usr/bin/env bash

### settings
WORK_DIR=/Volumes/WORK
export MAKEFLAGS="-j $(sysctl -n hw.ncpu)"
export HOMEBREW_TEMP=$WORK_DIR/brew.tmp
export BREW_DIR=$WORK_DIR/homebrew
export BREW_EXEC=$BREW_DIR/bin/brew
###

# 10 GiB ramdisk
diskutil erasevolume HFS+ "WORK" $(hdiutil attach -nomount ram://$(expr 10 \* 1024 \* 2048))
mkdir -p $HOMEBREW_TEMP

mkdir $BREW_DIR && curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C $BREW_DIR

$BREW_EXEC install \
cmake \
cairo \
boehmgc \
intltool \
libxslt \
lcms2 \
boost \
poppler \
gsl \
adwaita-icon-theme \
gdl \
gtkmm3 \
libsoup

# inkscape 0.92.4 only?
#popt

#diskutil unmount WORK

