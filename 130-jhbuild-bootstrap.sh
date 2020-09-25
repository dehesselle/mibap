#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later
#
# This file is part of the build pipeline for Inkscape on macOS.
#
# ### 130-jhbuild-bootstrap.sh ###
# Bootstrap the JHBuild environment.

### load global settings and functions #########################################

SELF_DIR=$(F=$0; while [ ! -z $(readlink $F) ] && F=$(readlink $F); cd $(dirname $F); F=$(basename $F); [ -L $F ]; do :; done; echo $(pwd -P))
for script in $SELF_DIR/0??-*.sh; do source $script; done

### local settings #############################################################

export PYTHONUSERBASE=$DEVPREFIX
export PIP_CONFIG_DIR=$DEVROOT/pip

### install and configure jhbuild ##############################################

bash <(curl -s $URL_GTK_OSX_SETUP)   # run jhbuild setup script

# JHBuild: paths
echo "checkoutroot = '$SRC_DIR/checkout'" >> $JHBUILDRC_CUSTOM
echo "prefix = '$OPT_DIR'"                >> $JHBUILDRC_CUSTOM
echo "tarballdir = '$SRC_DIR/download'"   >> $JHBUILDRC_CUSTOM

# JHBuild: console output
echo "quiet_mode = True"   >> $JHBUILDRC_CUSTOM
echo "progress_bar = True" >> $JHBUILDRC_CUSTOM

# JHBuild: moduleset
echo "moduleset = '$URL_GTK_OSX_MODULESET'" >> $JHBUILDRC_CUSTOM

# JHBuild: macOS SDK
sed -i "" "s/^setup_sdk/#setup_sdk/"                      $JHBUILDRC_CUSTOM
echo "setup_sdk(target=\"$SDK_VERSION\")" >> $JHBUILDRC_CUSTOM
echo "os.environ[\"SDKROOT\"]=\"$SDKROOT\""            >> $JHBUILDRC_CUSTOM

# JHBuild: TODO: I have forgotten why this is here
echo "if \"openssl\" in skip:"    >> $JHBUILDRC_CUSTOM
echo "  skip.remove(\"openssl\")" >> $JHBUILDRC_CUSTOM

# Remove harmful settings in regards to the target platform:
#   - MACOSX_DEPLOYMENT_TARGET
#   - -mmacosx-version-min
#
#   otool -l <library> | grep -A 3 -B 1 LC_VERSION_MIN_MACOSX
#
#           cmd LC_VERSION_MIN_MACOSX
#       cmdsize 16
#       version 10.11
#           sdk n/a          < - - - notarized app won't load this library
echo "os.environ.pop(\"MACOSX_DEPLOYMENT_TARGET\")" \
    >> $JHBUILDRC_CUSTOM
echo "os.environ[\"CFLAGS\"] = \"-O2 -I$SDKROOT/usr/include -isysroot $SDKROOT\"" \
    >> $JHBUILDRC_CUSTOM
echo "os.environ[\"CPPFLAGS\"] = \"-I$INC_DIR -I$SDKROOT/usr/include -isysroot $SDKROOT\"" \
    >> $JHBUILDRC_CUSTOM
echo "os.environ[\"CXXFLAGS\"] = \"-O2 -I$SDKROOT/usr/include -isysroot $SDKROOT\"" \
    >> $JHBUILDRC_CUSTOM
echo "os.environ[\"LDFLAGS\"] = \"-L$LIB_DIR -L$SDKROOT/usr/lib -isysroot $SDKROOT -Wl,-headerpad_max_install_names\"" \
    >> $JHBUILDRC_CUSTOM
echo "os.environ[\"OBJCFLAGS\"] = \"-O2 -I$SDKROOT/usr/include -isysroot $SDKROOT\"" \
    >> $JHBUILDRC_CUSTOM

### bootstrap JHBuild ##########################################################

jhbuild bootstrap-gtk-osx
