# SPDX-License-Identifier: GPL-2.0-or-later
#
# This file is part of the build pipeline for Inkscape on macOS.

### create configuration for JHBuild ###########################################

function configure_jhbuild
{
  # Copy JHBuild configuration files. We can't use 'cp' because that doesn't
  # with the ramdisk overlay.
  mkdir -p $(dirname $JHBUILDRC)
  cat $SELF_DIR/jhbuild/$(basename $JHBUILDRC)        > $JHBUILDRC
  cat $SELF_DIR/jhbuild/$(basename $JHBUILDRC_CUSTOM) > $JHBUILDRC_CUSTOM

  # set moduleset directory
  echo "modulesets_dir = '$SELF_DIR/jhbuild'" >> $JHBUILDRC_CUSTOM

  # basic directory layout
  echo "buildroot = '$BLD_DIR'"    >> $JHBUILDRC_CUSTOM
  echo "checkoutroot = '$SRC_DIR'" >> $JHBUILDRC_CUSTOM
  echo "prefix = '$VER_DIR'"       >> $JHBUILDRC_CUSTOM
  echo "tarballdir = '$PKG_DIR'"   >> $JHBUILDRC_CUSTOM

  # set macOS SDK
  echo "setup_sdk(sdkdir=\"$SDKROOT\")" >> $JHBUILDRC_CUSTOM

  # set release build
  echo "setup_release()" >> $JHBUILDRC_CUSTOM

  # enable ccache
  echo "os.environ[\"CC\"] = \"$BIN_DIR/gcc\""   >> $JHBUILDRC_CUSTOM
  echo "os.environ[\"OBJC\"] = \"$BIN_DIR/gcc\"" >> $JHBUILDRC_CUSTOM
  echo "os.environ[\"CXX\"] = \"$BIN_DIR/g++\""  >> $JHBUILDRC_CUSTOM

  # certificates for https
  echo "os.environ[\"SSL_CERT_FILE\"] = \
  \"$LIB_DIR/python$PY3_MAJOR.$PY3_MINOR/site-packages/certifi/cacert.pem\"" \
    >> $JHBUILDRC_CUSTOM
  echo "os.environ[\"REQUESTS_CA_BUNDLE\"] = \
  \"$LIB_DIR/python$PY3_MAJOR.$PY3_MINOR/site-packages/certifi/cacert.pem\"" \
    >> $JHBUILDRC_CUSTOM

  # user home directory
  echo "os.environ[\"HOME\"] = \"$HOME\"" >> $JHBUILDRC_CUSTOM

  # less noise on the terminal if not CI
  if ! $CI; then
    echo "quiet_mode = True"   >> $JHBUILDRC_CUSTOM
    echo "progress_bar = True" >> $JHBUILDRC_CUSTOM
  fi
}
