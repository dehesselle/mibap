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

# Set these here for JHBuild only.

export PYTHONUSERBASE=$DEVPREFIX
export PIP_CONFIG_DIR=$DEVROOT/pip

### install and configure JHBuild ##############################################

bash <(curl -s $URL_GTK_OSX_SETUP)   # run JHBuild setup script

# JHBuild: paths
echo "buildroot = '$DEVROOT/build'"        >> $JHBUILDRC_CUSTOM
echo "checkoutroot = '$DEV_SRC_ROOT'"      >> $JHBUILDRC_CUSTOM
echo "prefix = '$WRK_DIR'"                 >> $JHBUILDRC_CUSTOM
echo "tarballdir = '$DEV_SRC_ROOT/pkgs'"   >> $JHBUILDRC_CUSTOM

# JHBuild: console output
echo "quiet_mode = True"   >> $JHBUILDRC_CUSTOM
echo "progress_bar = True" >> $JHBUILDRC_CUSTOM

# JHBuild: moduleset
echo "moduleset = '$URL_GTK_OSX_MODULESET'" >> $JHBUILDRC_CUSTOM

# JHBuild: macOS SDK
sed -i "" "s/^setup_sdk/#setup_sdk/"                      $JHBUILDRC_CUSTOM
echo "setup_sdk(target=\"$MACOSX_DEPLOYMENT_TARGET\")" >> $JHBUILDRC_CUSTOM
echo "os.environ[\"SDKROOT\"]=\"$SDKROOT\""            >> $JHBUILDRC_CUSTOM

# JHBuild: TODO: I have forgotten why this is here
echo "if \"openssl\" in skip:"    >> $JHBUILDRC_CUSTOM
echo "  skip.remove(\"openssl\")" >> $JHBUILDRC_CUSTOM

if [ -d $CCACHE_BIN_DIR ]; then
  echo_o "building with ccache"
  echo "os.environ[\"CC\"] = \"$CCACHE_BIN_DIR/gcc\""  >> $JHBUILDRC_CUSTOM
  echo "os.environ[\"CXX\"] = \"$CCACHE_BIN_DIR/g++\"" >> $JHBUILDRC_CUSTOM
else
  echo_w "building without ccache (set CCACHE_BIN_DIR)"
fi

### bootstrap JHBuild ##########################################################

jhbuild bootstrap-gtk-osx
