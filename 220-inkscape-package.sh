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

# add XDG paths to use native locations on macOS
insert_before $APP_EXE_DIR/Inkscape 'export XDG_CONFIG_DIRS' '\
export XDG_DATA_HOME=\"$HOME/Library/Application Support/Inkscape/data\"\
export XDG_CONFIG_HOME=\"$HOME/Library/Application Support/Inkscape/config\"\
export XDG_CACHE_HOME=\"$HOME/Library/Application Support/Inkscape/cache\"\
mkdir -p $XDG_DATA_HOME\
mkdir -p $XDG_CONFIG_HOME\
mkdir -p $XDG_CACHE_HOME\
'

# add icon
# TODO: create from Inkscape assets on-the-fly
curl -L -o $APP_RES_DIR/inkscape.icns $URL_INKSCAPE_ICNS

if [ -z $CI_JOB_ID ]; then   # running standalone
  # update version information
  /usr/libexec/PlistBuddy -c "Set CFBundleShortVersionString '1.0alpha2-g$(get_repo_version $SRC_DIR/inkscape)'" $APP_PLIST
  /usr/libexec/PlistBuddy -c "Set CFBundleVersion '1.0alpha2-g$(get_repo_version $SRC_DIR/inkscape)'" $APP_PLIST
else   # running as CI job
  # update version information
  /usr/libexec/PlistBuddy -c "Set CFBundleShortVersionString '1.0alpha2-g$(get_repo_version $SELF_DIR)'" $APP_PLIST
  /usr/libexec/PlistBuddy -c "Set CFBundleVersion '1.0alpha2-g$(get_repo_version $SELF_DIR)'" $APP_PLIST
fi

### copy Python.framework ######################################################

# This section deals with bundling Python.framework into the application.
mkdir $APP_CON_DIR/Frameworks
get_source $URL_PYTHON3 $APP_CON_DIR/Frameworks

# add it to '$PATH'
insert_before $APP_EXE_DIR/Inkscape '\$EXEC' 'export PATH=$bundle_contents/Frameworks/Python.framework/Versions/Current/bin:$PATH'

### install Python packages ####################################################

# Install Python packages required by default Inkscape extensions.

# use Python interpreter from Python.framework
export PATH=$APP_CON_DIR/Frameworks/Python.framework/Versions/Current/bin:$PATH

pip3 install --install-option="--prefix=$APP_RES_DIR" --ignore-installed lxml==4.3.3
pip3 install --install-option="--prefix=$APP_RES_DIR" --ignore-installed numpy==1.16.4

# add it to '$PYTHONPATH'
insert_before $APP_EXE_DIR/Inkscape '\$EXEC' 'export PYTHONPATH=$PYTHONPATH:$APP_LIB_DIR/python3.6'

### fontconfig #################################################################

# Mimic the behavior of having all files under 'share' and linking the
# active ones to 'etc'.
cd $APP_ETC_DIR/fonts/conf.d

for file in ./*.conf; do
  ln -sf ../../../share/fontconfig/conf.avail/$(basename $file)
done

# Set environment variable so fontconfig looks in the right place for its
# files. (https://www.freedesktop.org/software/fontconfig/fontconfig-user.html)
insert_before $APP_EXE_DIR/Inkscape '\$EXEC' \
  'export FONTCONFIG_PATH=$bundle_res/etc/fonts'

# Our customized version loses all the non-macOS paths and sets a cache
# directory below '$HOME/Library/Application Support/Inkscape'.
cp $SELF_DIR/fonts.conf $APP_ETC_DIR/fonts

### GIO modules path ###########################################################

# Set environment variable for GIO to find its modules.
# (https://developer.gnome.org/gio//2.52/running-gio-apps.html)
insert_before $APP_EXE_DIR/Inkscape '\$EXEC' 'export GIO_MODULE_DIR=$bundle_lib/gio/modules'

