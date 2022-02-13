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
  certifi==2021.10.8\
  meson==0.59.2\
  ninja==1.10.2.2\
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
# later.
JHBUILD_PYTHON_VER_MAJOR=3
JHBUILD_PYTHON_VER_MINOR=8
JHBUILD_PYTHON_VER=$JHBUILD_PYTHON_VER_MAJOR.$JHBUILD_PYTHON_VER_MINOR
JHBUILD_PYTHON_URL="https://gitlab.com/api/v4/projects/26780227/packages/\
generic/python_macos/6/python_${JHBUILD_PYTHON_VER/./}_$(uname -p).tar.xz"
JHBUILD_PYTHON_DIR=$OPT_DIR/Python.framework/Versions/$JHBUILD_PYTHON_VER
JHBUILD_PYTHON_BIN_DIR=$JHBUILD_PYTHON_DIR/bin

export JHBUILD_PYTHON_BIN=$JHBUILD_PYTHON_BIN_DIR/python$JHBUILD_PYTHON_VER
export JHBUILD_PYTHON_PIP=$JHBUILD_PYTHON_BIN_DIR/pip$JHBUILD_PYTHON_VER

### functions ##################################################################

function jhbuild_set_interpreter
{
  for dir in $BIN_DIR $JHBUILD_PYTHON_BIN_DIR; do
    while IFS= read -r -d '' file; do
      local file_type
      file_type=$(file "$file")
      if [[ $file_type = *"Python script"* ]]; then
        sed -i "" "1 s|.*|#!$JHBUILD_PYTHON_BIN|" "$file"
      fi
    done < <(find "$dir"/ -type f -maxdepth 1 -print0)
  done
}

function jhbuild_install_python
{
  # Download and extract Python.framework to OPT_DIR.
  mkdir -p "$OPT_DIR"
  curl -L "$JHBUILD_PYTHON_URL" | tar -C "$OPT_DIR" -x

  jhbuild_set_interpreter

  # create '.pth' file inside Framework to include our site-packages directory
  echo "../../../../../../../lib/python$JHBUILD_PYTHON_VER/site-packages"\
    > "$OPT_DIR"/Python.framework/Versions/$JHBUILD_PYTHON_VER/lib/\
python$JHBUILD_PYTHON_VER/site-packages/jhbuild.pth
}

function jhbuild_install
{
  # We use our own custom Python, even if the system provides one.
  jhbuild_install_python

  # Install dependencies.
  # shellcheck disable=SC2086 # we need word splitting for requirements
  $JHBUILD_PYTHON_PIP install --prefix=$VER_DIR $JHBUILD_REQUIREMENTS

  function pem_remove_expired
  {
    local pem_bundle=$1

    # BSD's csplit does not support '{*}' (it's a GNU extension)
    csplit -n 3 -k -f "$TMP_DIR"/pem- "$pem_bundle" \
     '/END CERTIFICATE/+1' '{999}' >/dev/null || true

    for pem in "$TMP_DIR"/pem-*; do
      if ! openssl x509 -checkend 0 -noout -in "$pem"; then
        echo_i "removing $pem: $(openssl x509 -enddate -noout -in "$pem")"
        cat "$pem"
        rm "$pem"
      fi
    done

    cat "$TMP_DIR"/pem-??? > "$pem_bundle"
  }

  pem_remove_expired \
    "$LIB_DIR"/python$JHBUILD_PYTHON_VER/site-packages/certifi/cacert.pem

  # Download JHBuild.
  local archive
  archive=$PKG_DIR/$(basename $JHBUILD_URL)
  curl -o "$archive" -L "$JHBUILD_URL"
  tar -C "$SRC_DIR" -xf "$archive"

  ( # Install JHBuild.
    cd "$SRC_DIR"/jhbuild-$JHBUILD_VER || exit 1
    export PATH=$JHBUILD_PYTHON_BIN_DIR:$PATH
    ./autogen.sh --prefix="$VER_DIR"
    make
    make install
  )

  jhbuild_set_interpreter
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

    # setup moduleset
    echo "modulesets_dir = '$SELF_DIR/jhbuild'"
    echo "moduleset = 'inkscape.modules'"
    echo "use_local_modulesets = True"

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

    # Use compiler binaries from our own BIN_DIR if present. The intention is
    # that these are symlinks pointing to ccache if that has been installed
    # (see ccache.sh for details).
    if [ -x "$BIN_DIR/gcc" ]; then
      echo "os.environ[\"CC\"] = \"$BIN_DIR/gcc\""
      echo "os.environ[\"OBJC\"] = \"$BIN_DIR/gcc\""
    fi
    if [ -x "$BIN_DIR/g++" ]; then
      echo "os.environ[\"CXX\"] = \"$BIN_DIR/g++\""
    fi

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