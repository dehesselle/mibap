# SPDX-FileCopyrightText: 2021 René de Hesselle <dehesselle@web.de>
#
# SPDX-License-Identifier: GPL-2.0-or-later

### description ################################################################

# Download, install and configure JHBuild.

### shellcheck #################################################################

# shellcheck shell=bash # no shebang as this file is intended to be sourced

### dependencies ###############################################################

# Nothing here.

### variables ##################################################################

export JHBUILDRC=$ETC_DIR/jhbuildrc
export JHBUILDRC_CUSTOM=$JHBUILDRC-custom

JHBUILD_REQUIREMENTS="\
  certifi==2021.5.30\
  meson==0.57.1\
  ninja==1.10.0.post2\
  pygments==2.8.1\
"

# JHBuild build system 3.38.0+ (a896cbf404461cab979fa3cd1c83ddf158efe83b)
# from master branch because of specific patch
# https://gitlab.gnome.org/GNOME/jhbuild
# https://wiki.gnome.org/Projects/Jhbuild/Introduction
JHBUILD_VER=a896cbf
JHBUILD_URL=https://gitlab.gnome.org/GNOME/jhbuild/-/archive/$JHBUILD_VER/\
jhbuild-$JHBUILD_VER.tar.bz2


# We install a dedicated Python runtime for JHBuild. It is installed and
# kept separately from the rest of this system. This does not interfere
# with the Python runtime that gets build when building all our libraries
# later
JHBUILD_PYTHON_VER_MAJOR=3
JHBUILD_PYTHON_VER_MINOR=8
JHBUILD_PYTHON_VER=$JHBUILD_PYTHON_VER_MAJOR.$JHBUILD_PYTHON_VER_MINOR
JHBUILD_PYTHON_URL="https://gitlab.com/dehesselle/python_macos/-/jobs/\
artifacts/master/raw/python_${JHBUILD_PYTHON_VER//.}_$(uname -p).tar.xz?\
job=python${JHBUILD_PYTHON_VER//.}:$(uname -p)"
JHBUILD_PYTHON_DIR=$OPT_DIR/Python.framework/Versions/$JHBUILD_PYTHON_VER
JHBUILD_PYTHON_BIN_DIR=$JHBUILD_PYTHON_DIR/bin

export JHBUILD_PYTHON_BIN=$JHBUILD_PYTHON_BIN_DIR/python$JHBUILD_PYTHON_VER
export JHBUILD_PYTHON_PIP=$JHBUILD_PYTHON_BIN_DIR/pip$JHBUILD_PYTHON_VER

### functions ##################################################################

function jhbuild_install_python
{
  # Download and extract Python.framework to OPT_DIR.
  mkdir -p "$OPT_DIR"
  curl -L "$JHBUILD_PYTHON_URL" | tar -C "$OPT_DIR" -x

  # Create a pkg-config configuration to match our installation location.
  # Note: sed changes the prefix and exec_prefix lines!
  mkdir -p "$LIB_DIR"/pkgconfig
  cp "$JHBUILD_PYTHON_DIR"/lib/pkgconfig/python-$JHBUILD_PYTHON_VER*.pc \
    "$LIB_DIR"/pkgconfig
  sed -i "" "s/prefix=.*/prefix=$(sed_escape_str "$JHBUILD_PYTHON_DIR")/" \
    "$LIB_DIR"/pkgconfig/python-$JHBUILD_PYTHON_VER.pc
  sed -i "" "s/prefix=.*/prefix=$(sed_escape_str "$JHBUILD_PYTHON_DIR")/" \
    "$LIB_DIR"/pkgconfig/python-$JHBUILD_PYTHON_VER-embed.pc

  # Link binaries to our BIN_DIR.
  ln -s "$JHBUILD_PYTHON_BIN" "$BIN_DIR"/python$JHBUILD_PYTHON_VER
  ln -s "$JHBUILD_PYTHON_BIN" "$BIN_DIR"/python$JHBUILD_PYTHON_VER_MAJOR

  # Shadow the system's python binary as well.
  ln -s python$JHBUILD_PYTHON_VER_MAJOR "$BIN_DIR"/python
}

function jhbuild_install
{
  # We use our own custom Python, even if the system provides one.
  jhbuild_install_python

  # Install dependencies.
  # shellcheck disable=SC2086 # we need word splitting for requirements
  "$JHBUILD_PYTHON_BIN_DIR"/pip$JHBUILD_PYTHON_VER \
    install --prefix="$VER_DIR" $JHBUILD_REQUIREMENTS

  # Remove expired Lets's Encrypt root certificate.
  patch -b -d "$LIB_DIR"/python$JHBUILD_PYTHON_VER/site-packages/certifi \
    -p1 < "$SELF_DIR"/packages/patches/certifi_remove_expired.patch

  # Download JHBuild.
  local archive
  archive=$PKG_DIR/$(basename $JHBUILD_URL)
  curl -o "$archive" -L "$JHBUILD_URL"
  tar -C "$SRC_DIR" -xf "$archive"

  ( # Install JHBuild.
    cd "$SRC_DIR"/jhbuild-$JHBUILD_VER || exit 1
    ./autogen.sh \
      --prefix="$VER_DIR" \
      --with-python="$JHBUILD_PYTHON_BIN_DIR"/python$JHBUILD_PYTHON_VER
    make
    make install

    sed -i "" \
      "1 s/.*/#!$(sed_escape_str "$BIN_DIR/python$JHBUILD_PYTHON_VER")/" \
      "$BIN_DIR"/jhbuild
  )
}

function jhbuild_configure
{
  # Copy JHBuild configuration files. We can't use 'cp' because that doesn't
  # work with the ramdisk overlay.
  mkdir -p "$(dirname "$JHBUILDRC")"
  # shellcheck disable=SC2094 # not the same file
  cat "$SELF_DIR"/jhbuild/"$(basename "$JHBUILDRC")" > "$JHBUILDRC"

  {
    echo "# -*- mode: python -*-"

    # set moduleset directory
    echo "modulesets_dir = '$SELF_DIR/jhbuild'"

    # basic directory layout
    echo "buildroot = '$BLD_DIR'"
    echo "checkoutroot = '$SRC_DIR'"
    echo "prefix = '$VER_DIR'"
    echo "tarballdir = '$PKG_DIR'"
    echo "top_builddir = '$VAR_DIR/jhbuild'"

    # set macOS SDK
    echo "setup_sdk(sdkdir=\"$SDKROOT\")"

    # set release build
    echo "setup_release()"

    # enable ccache
    echo "os.environ[\"CC\"] = \"$BIN_DIR/gcc\""
    echo "os.environ[\"OBJC\"] = \"$BIN_DIR/gcc\""
    echo "os.environ[\"CXX\"] = \"$BIN_DIR/g++\""

    # certificates for https
    echo "os.environ[\"SSL_CERT_FILE\"] = \
      \"$LIB_DIR/python$JHBUILD_PYTHON_VER/site-packages/certifi/cacert.pem\""
    echo "os.environ[\"REQUESTS_CA_BUNDLE\"] = \
      \"$LIB_DIR/python$JHBUILD_PYTHON_VER/site-packages/certifi/cacert.pem\""

    # user home directory
    echo "os.environ[\"HOME\"] = \"$HOME\""

    # less noise on the terminal if not CI
    if ! $CI; then
      echo "quiet_mode = True"
      echo "progress_bar = True"
    fi

  } > "$JHBUILDRC_CUSTOM"
}

### main #######################################################################

# Nothing here.