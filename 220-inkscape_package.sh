#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later
#
# This file is part of the build pipeline for Inkscape on macOS.
#
# ### 220-inkscape_package.sh ###
# Create Inkscape application bundle.

### settings and functions #####################################################

# shellcheck disable=SC2164 # we have error trapping that catches bad 'cd'

# shellcheck disable=SC1090 # can't point to a single source here
for script in "$(dirname "${BASH_SOURCE[0]}")"/0??-*.sh; do source "$script"; done

include_file ansi_.sh
include_file error_.sh
error_trace_enable

# shellcheck disable=SC2034 # var is from ansi_.sh
ANSI_TERM_ONLY=false   # use ANSI control characters even if not in terminal

### variables ##################################################################

INK_APP_SITEPKG_DIR=$INK_APP_LIB_DIR/python$INK_PYTHON_VER/site-packages

#-- create application bundle --------------------------------------------------

mkdir -p "$ARTIFACT_DIR"

( # run gtk-mac-bundler

  BUILD_DIR=$SRC_DIR/gtk-mac-bundler.build
  mkdir -p "$BUILD_DIR"

  cp "$SELF_DIR"/inkscape.bundle "$BUILD_DIR"
  cp "$SELF_DIR"/inkscape.plist "$BUILD_DIR"

  export ARTIFACT_DIR   # referenced in inkscape.bundle
  cd "$BUILD_DIR"
  jhbuild run gtk-mac-bundler inkscape.bundle
)

# Rename to get from lowercase to capitalized "i". This works only on
# case-insensitive filesystems (default on macOS).
mv "$INK_APP_DIR" "$INK_APP_DIR".tmp
mv "$INK_APP_DIR".tmp "$INK_APP_DIR"

# patch library link paths for lib2geom
lib_change_path \
  @executable_path/../Resources/lib/lib2geom\\..+dylib \
  "$INK_APP_LIB_DIR"/inkscape/libinkscape_base.dylib

# patch library link path for libboost_filesystem
lib_change_path \
  @executable_path/../Resources/lib/libboost_filesystem.dylib \
  "$INK_APP_LIB_DIR"/inkscape/libinkscape_base.dylib \
  "$INK_APP_EXE_DIR"/inkscape

# patch library link path for libinkscape_base
lib_change_path \
  @executable_path/../Resources/lib/inkscape/libinkscape_base.dylib \
  "$INK_APP_EXE_DIR"/inkscape

lib_change_siblings "$INK_APP_LIB_DIR"

( # update version numbers in property list

  PLIST=$INK_APP_CON_DIR/Info.plist
  IV=$(ink_get_version)
  RV=$(ink_get_repo_shorthash)

  # update Inkscape version information
  /usr/libexec/PlistBuddy -c "Set CFBundleShortVersionString '$IV ($RV)'" "$PLIST"
  /usr/libexec/PlistBuddy -c "Set CFBundleVersion '$IV ($RV)'" "$PLIST"

  # update minimum system version according to deployment target
  /usr/libexec/PlistBuddy -c "Set LSMinimumSystemVersion '$SDK_VER'" "$PLIST"
)

#-- generate application icon --------------------------------------------------

svg2icns "$INK_DIR"/share/branding/inkscape-mac.svg "$INK_APP_RES_DIR"/inkscape.icns

#-- add file type icons --------------------------------------------------------

cp "$INK_DIR"/packaging/macos/resources/*.icns "$INK_APP_RES_DIR"

#-- bundle Python.framework ----------------------------------------------------

# This section deals with bundling Python.framework into the application.

mkdir "$INK_APP_FRA_DIR"
install_source file://"$PKG_DIR"/"$(basename "$PYTHON_INK_URL")" "$INK_APP_FRA_DIR" \
  --exclude="Versions/$INK_PYTHON_VER/lib/python$INK_PYTHON_VER/test/"'*'

# link it to $INK_APP_BIN_DIR so it'll be in $PATH for the app
mkdir -p "$INK_APP_BIN_DIR"
# shellcheck disable=SC2086 # it's an integer
ln -sf ../../Frameworks/Python.framework/Versions/Current/bin/python$INK_PYTHON_VER_MAJOR "$INK_APP_BIN_DIR"

# create '.pth' file inside Framework to include our site-packages directory
# shellcheck disable=SC2086 # it's an integer
# TODO: remove "./" ?
echo "./../../../../../../../Resources/lib/python$INK_PYTHON_VER/site-packages" \
  > "$INK_APP_FRA_DIR"/Python.framework/Versions/Current/lib/python$INK_PYTHON_VER/site-packages/inkscape.pth

#-- install Python package: lxml -----------------------------------------------

ink_pipinstall "$INK_PYTHON_LXML"

lib_change_paths \
  @loader_path/../../.. \
  "$INK_APP_LIB_DIR" \
  "$INK_APP_SITEPKG_DIR"/lxml/etree.cpython-"${INK_PYTHON_VER/./}"-darwin.so \
  "$INK_APP_SITEPKG_DIR"/lxml/objectify.cpython-"${INK_PYTHON_VER/./}"-darwin.so

#-- install Python package: NumPy ----------------------------------------------

ink_pipinstall "$INK_PYTHON_NUMPY"
rm "$INK_APP_BIN_DIR"/f2p*

#-- install Python package: PyGObject ------------------------------------------

ink_pipinstall "$INK_PYTHON_PYGOBJECT"

lib_change_paths \
  @loader_path/../../.. \
  "$INK_APP_LIB_DIR" \
  "$INK_APP_SITEPKG_DIR"/gi/_gi.cpython-"${INK_PYTHON_VER/./}"-darwin.so \
  "$INK_APP_SITEPKG_DIR"/gi/_gi_cairo.cpython-"${INK_PYTHON_VER/./}"-darwin.so

#-- install Python package: Pycairo --------------------------------------------

# This package got pulled in by PyGObject.

# patch '_cairo'
lib_change_paths \
  @loader_path/../../.. \
  "$INK_APP_LIB_DIR" \
  "$INK_APP_SITEPKG_DIR"/cairo/_cairo.cpython-"${INK_PYTHON_VER/./}"-darwin.so

#-- install Python package: pySerial -------------------------------------------

ink_pipinstall "$INK_PYTHON_PYSERIAL"
find "$INK_APP_SITEPKG_DIR"/serial -type f -name "*.pyc" -exec rm {} \;
rm "$INK_APP_BIN_DIR"/miniterm.*

#-- install Python package: Scour ----------------------------------------------

ink_pipinstall "$INK_PYTHON_SCOUR"
rm "$INK_APP_BIN_DIR"/scour

#-- remove Python cache files --------------------------------------------------

rm -rf "$INK_APP_RES_DIR"/share/glib-2.0/codegen/__pycache__

#-- fontconfig -----------------------------------------------------------------

# Mimic the behavior of having all files under 'share' and linking the
# active ones to 'etc'.
cd "$INK_APP_ETC_DIR"/fonts/conf.d

for file in ./*.conf; do
  ln -sf ../../../share/fontconfig/conf.avail/"$(basename "$file")" .
done

# Our customized version loses all the non-macOS paths and sets a cache
# directory below '$HOME/Library/Application Support/Inkscape'.
cp "$SELF_DIR"/fonts.conf "$INK_APP_ETC_DIR"/fonts

#-- create GObject introspection repository ------------------------------------

mkdir "$INK_APP_LIB_DIR"/girepository-1.0

# remove fully qualified paths from libraries in *.gir files
for gir in "$VER_DIR"/share/gir-1.0/*.gir; do
  sed "s/$(escape_sed "$LIB_DIR"/)//g" "$gir" > "$SRC_DIR"/"$(basename "$gir")"
done

# compile *.gir into *.typelib files
for gir in "$SRC_DIR"/*.gir; do
  jhbuild run g-ir-compiler \
    -o "$INK_APP_LIB_DIR"/girepository-1.0/"$(basename -s .gir "$gir")".typelib "$gir"
done
