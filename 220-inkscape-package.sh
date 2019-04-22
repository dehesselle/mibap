#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later
#
# This file is part of the build pipeline for Inkscape on macOS.
#
# ### 220-inkscape-package.sh ###
# Create Inkscape application bundle.

### load settings and functions ################################################

SELF_DIR=$(cd $(dirname "$0"); pwd -P)
for script in $SELF_DIR/0??-*.sh; do source $script; done

set -e

### package Inkscape ###########################################################

mkdir -p $ARTIFACT_DIR
export    ARTIFACT_DIR   # referenced in 'inkscape.bundle'

cp $SRC_DIR/gtk-mac-bundler*/examples/gtk3-launcher.sh $SELF_DIR
cd $SELF_DIR
jhbuild run gtk-mac-bundler inkscape.bundle

# patch library locations
install_name_tool -change @rpath/libinkscape_base.dylib @executable_path/../Resources/lib/inkscape/libinkscape_base.dylib $APP_EXE_DIR/Inkscape-bin
install_name_tool -change @rpath/libpoppler.85.dylib @executable_path/../Resources/lib/libpoppler.85.dylib $APP_LIB_DIR/libpoppler-glib.8.dylib
install_name_tool -change @rpath/libpoppler.85.dylib @executable_path/../Resources/lib/libpoppler.85.dylib $APP_LIB_DIR/inkscape/libinkscape_base.dylib
install_name_tool -change @rpath/libpoppler-glib.8.dylib @executable_path/../Resources/lib/libpoppler-glib.8.dylib $APP_LIB_DIR/inkscape/libinkscape_base.dylib

install_name_tool -change @executable_path/../Resources/lib/libcrypto.1.1.dylib @loader_path/libcrypto.1.1.dylib $APP_LIB_DIR/libssl.1.1.dylib


# patch the launch script
# TODO: as follow-up to https://gitlab.com/inkscape/inkscape/merge_requests/612,
# it should not be necessary to rely on $INKSCAPE_DATADIR. Paths in
# 'path-prefix.h' are supposed to work. Needs to be looked into with @ede123.

insert_before $APP_EXE_DIR/Inkscape '\$EXEC' 'export INKSCAPE_DATADIR=$bundle_data'
insert_before $APP_EXE_DIR/Inkscape '\$EXEC' 'export INKSCAPE_LOCALEDIR=$bundle_data/locale'

# add XDG paths
insert_before $APP_EXE_DIR/Inkscape 'export XDG_CONFIG_DIRS' '\
export XDG_DATA_HOME=\"$HOME/Library/Application Support/Inkscape/data\"\
export XDG_CONFIG_HOME=\"$HOME/Library/Application Support/Inkscape/config\"\
export XDG_CACHE_HOME=\"$HOME/Library/Application Support/Inkscape/cache\"\
mkdir -p $XDG_DATA_HOME\
mkdir -p $XDG_CONFIG_HOME\
mkdir -p $XDG_CACHE_HOME\
'

# add Python paths
insert_before $APP_EXE_DIR/Inkscape '\$EXEC' 'export PATH=$bundle_bin:$PATH'

mkdir -p $APP_BIN_DIR
cd $APP_BIN_DIR
ln -s ../../Frameworks/Python.framework/Versions/3.6/bin/python3.6 python

# copy Python framework to app bundle
rsync -a $OPT_DIR/Frameworks $APP_CON_DIR

# patch python library location
chmod 644 $APP_CON_DIR/Frameworks/Python.framework/Versions/3.6/Python
install_name_tool -change $LIB_DIR/libintl.9.dylib @loader_path/../../../../Resources/lib/libintl.9.dylib  $APP_CON_DIR/Frameworks/Python.framework/Versions/3.6/Python
# patch python app inside framework
install_name_tool -change $LIB_DIR/libintl.9.dylib @executable_path/../../../../../../../../Resources/lib/libintl.9.dylib  $APP_CON_DIR/Frameworks/Python.framework/Resources/Python.app/Contents/MacOS/Python

install_name_tool -change $LIB_DIR/libssl.1.1.dylib @loader_path/../../../../../../../Resources/lib/libssl.1.1.dylib $APP_CON_DIR/Frameworks/Python.framework/Versions/3.6/lib/python3.6/lib-dynload/_ssl*.so
install_name_tool -change $LIB_DIR/libcrypto.1.1.dylib @loader_path/../../../../../../../Resources/lib/libcrypto.1.1.dylib $APP_CON_DIR/Frameworks/Python.framework/Versions/3.6/lib/python3.6/lib-dynload/_ssl*.so

# add icon
# TODO: create from Inkscape assets on-the-fly
curl -L -o $APP_RES_DIR/inkscape.icns $URL_INKSCAPE_ICNS

if [ -z $CI_JOB_ID ]; then   # running standalone
  # update version information
  /usr/libexec/PlistBuddy -c "Set CFBundleShortVersionString '1.0alpha-g$(get_repo_version $SRC_DIR/inkscape)'" $APP_PLIST
  /usr/libexec/PlistBuddy -c "Set CFBundleVersion '1.0alpha-g$(get_repo_version $SRC_DIR/inkscape)'" $APP_PLIST
else   # running as CI job
  # update version information
  /usr/libexec/PlistBuddy -c "Set CFBundleShortVersionString '1.0alpha-g$(get_repo_version $SELF_DIR)'" $APP_PLIST
  /usr/libexec/PlistBuddy -c "Set CFBundleVersion '1.0alpha-g$(get_repo_version $SELF_DIR)'" $APP_PLIST
fi

### create disk image for distribution #########################################

# TODO

if [ ! -z $CI_JOB_ID ]; then   # create build artifcat for CI job
  cd $WRK_DIR
  mv $ARTIFACT_DIR $SELF_DIR/../../build
fi
