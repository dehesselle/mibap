#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: 2021 René de Hesselle <dehesselle@web.de>
#
# SPDX-License-Identifier: GPL-2.0-or-later

### description ################################################################

# Create the application bundle and make everything relocatable.

### shellcheck #################################################################

# Nothing here.

### dependencies ###############################################################

source "$(dirname "${BASH_SOURCE[0]}")"/jhb/etc/jhb.conf.sh

bash_d_include error
bash_d_include lib

### variables ##################################################################

SELF_DIR=$(dirname "$(greadlink -f "$0")")

### functions ##################################################################

# Nothing here.

### main #######################################################################

error_trace_enable

#----------------------------------------------------- create application bundle

( # run gtk-mac-bundler

  cp "$SELF_DIR"/resources/inkscape.bundle "$INK_BLD_DIR"
  cp "$SELF_DIR"/resources/inkscape.plist "$INK_BLD_DIR"

  cd "$INK_BLD_DIR" || exit 1
  export ART_DIR=$ART_DIR # referenced in inkscape.bundle
  jhb run gtk-mac-bundler inkscape.bundle
)

# Rename to get from lowercase "i" to capitalized "I" as the app bundle name
# depends on the main binary (and that was lowercase in 0.9x).
mv "$INK_APP_DIR" "$INK_APP_DIR".tmp # requires case-insensitive filesysystem
mv "$INK_APP_DIR".tmp "$INK_APP_DIR"

# Create versionless symlink to libinkscape_base.
ln -sf "$(basename "$INK_APP_LIB_DIR"/inkscape/libinkscape_base.1.*.dylib)" \
  "$INK_APP_LIB_DIR/inkscape/libinkscape_base.dylib"

#----------------------------------------------------- adjust library link paths

# Add rpath according to our app bundle structure.
lib_clear_rpath "$INK_APP_EXE_DIR"/inkscape
lib_add_rpath @executable_path/../Resources/lib "$INK_APP_EXE_DIR"/inkscape
lib_add_rpath @executable_path/../Resources/lib/inkscape \
  "$INK_APP_EXE_DIR"/inkscape

# Libraries in INK_APP_LIB_DIR can reference each other directly.
lib_change_siblings "$INK_APP_LIB_DIR"

# Point GTK modules towards INK_APP_LIB_DIR using @loader_path.
lib_change_paths @loader_path/../../.. "$INK_APP_LIB_DIR" \
  "$INK_APP_LIB_DIR"/gtk-3.0/3.0.0/immodules/*.so \
  "$INK_APP_LIB_DIR"/gtk-3.0/3.0.0/printbackends/*.so

# Point GIO modules towards INK_APP_LIB_DIR using @loader_path.
lib_change_paths @loader_path/../.. "$INK_APP_LIB_DIR" \
  "$INK_APP_LIB_DIR"/gio/modules/*.so

# Point enchant's applespell plugin towards INK_APP_LIB_DIR using @loader_path.
lib_change_paths @loader_path/.. "$INK_APP_LIB_DIR" \
  "$INK_APP_LIB_DIR"/enchant-2/enchant_applespell.so

# Point Ghostscript towards INK_APP_LIB_DIR using @executable_path.
lib_change_paths \
  @executable_path/../lib \
  "$INK_APP_LIB_DIR" \
  "$INK_APP_BIN_DIR"/gs

# Point libproxy towards its backend using @loader_path.
lib_change_path \
  @loader_path/libproxy/libpxbackend-1.0.dylib \
  "$INK_APP_LIB_DIR"/libproxy.1.dylib

#------------------------------------------------------ use rpath in cache files

sed -i '' \
  's|@executable_path/../Resources/lib|@rpath|g' \
  "$INK_APP_LIB_DIR"/gtk-3.0/3.0.0/immodules.cache
sed -i '' \
  's|@executable_path/../Resources/lib|@rpath|g' \
  "$INK_APP_LIB_DIR"/gdk-pixbuf-2.0/2.10.0/loaders.cache

#------------------------------------------------------------- modify Info.plist

# update Inkscape version information
/usr/libexec/PlistBuddy \
  -c "Set CFBundleShortVersionString '$(ink_get_version)'" \
  "$INK_APP_PLIST"
/usr/libexec/PlistBuddy \
  -c "Set CFBundleVersion '$INK_BUILD'" \
  "$INK_APP_PLIST"

# update minimum system version according to deployment target
if [ -z "$MACOSX_DEPLOYMENT_TARGET" ]; then
  MACOSX_DEPLOYMENT_TARGET=$SYS_SDK_VER
fi
/usr/libexec/PlistBuddy \
  -c "Set LSMinimumSystemVersion $MACOSX_DEPLOYMENT_TARGET" \
  "$INK_APP_PLIST"

# add some metadata to make CI identifiable
if $CI_GITLAB; then
  for var in PROJECT_NAME PROJECT_URL COMMIT_BRANCH COMMIT_SHA \
    COMMIT_SHORT_SHA JOB_ID JOB_URL JOB_NAME PIPELINE_ID PIPELINE_URL; do
    # use awk to create camel case strings (e.g. PROJECT_NAME to ProjectName)
    /usr/libexec/PlistBuddy -c "Add CI$(
      echo $var | awk -F _ '{
        for (i=1; i<=NF; i++)
        printf "%s", toupper(substr($i,1,1)) tolower(substr($i,2))
      }'
    ) string $(eval echo \$CI_$var)" "$INK_APP_PLIST"
  done
fi

#----------------------------------------------------- generate application icon

svg2icns \
  "$INK_DIR"/share/branding/inkscape-mac.svg \
  "$INK_APP_RES_DIR"/inkscape.icns

#----------------------------------------------------------- add file type icons

cp "$INK_DIR"/packaging/macos/res/*.icns "$INK_APP_RES_DIR"

#------------------------------------------------------- add Python and packages

# Install externally built Python framework.
ink_install_python

# Add rpath to find libraries.
lib_add_rpath @executable_path/../../../../../Resources/lib \
  "$INK_APP_FRA_DIR/Python.framework/Versions/Current/bin/python$INK_PYTHON_VER"
lib_add_rpath @executable_path/../../../../../../../../Resources/lib \
  "$INK_APP_FRA_DIR/Python.framework/Versions/Current/Resources/Python.app/\
Contents/MacOS/Python"

# Install wheels.
ink_pipinstall INK_PYTHON_PKG_AIIMPORT       # AI import extension
ink_pipinstall INK_PYTHON_PKG_APPDIRS        # extension manager
ink_pipinstall INK_PYTHON_PKG_BEAUTIFULSOUP4 # extension manager
ink_pipinstall INK_PYTHON_PKG_CACHECONTROL   # extension manager
ink_pipinstall INK_PYTHON_PKG_CSSSELECT      #
ink_pipinstall INK_PYTHON_PKG_LXML           #
ink_pipinstall INK_PYTHON_PKG_NUMPY          #
ink_pipinstall INK_PYTHON_PKG_PILLOW         # export raster extension
ink_pipinstall INK_PYTHON_PKG_PYGOBJECT      #
ink_pipinstall INK_PYTHON_PKG_PYSERIAL       #
ink_pipinstall INK_PYTHON_PKG_SCOUR          #
ink_pipinstall INK_PYTHON_PKG_TINYCSS2       #

# Reset Python interpreter shebang in all scripts.
# shellcheck disable=SC2044 # fragile for loop
for file in $(find "$INK_APP_BIN_DIR" -type f); do
  if [[ $(file -b "$file") = *Python* ]]; then
    gsed -i '1s|.*|#!/usr/bin/env python3|' "$file"
  fi
done

#----------------------------------------------------- remove Python cache files

rm -rf "$INK_APP_RES_DIR"/share/glib-2.0/codegen/__pycache__

#-------------------------------------------------- add fontconfig configuration

# Mimic the behavior of having all files under 'share' and linking the
# active ones to 'etc'.
cd "$INK_APP_ETC_DIR"/fonts/conf.d || exit 1

for file in ./*.conf; do
  ln -sf ../../../share/fontconfig/conf.avail/"$(basename "$file")" .
done

# Our customized version loses all the non-macOS paths and sets a cache
# directory below '$HOME/Library/Application Support/Inkscape'.
cp "$SELF_DIR"/resources/fonts.conf "$INK_APP_ETC_DIR"/fonts

#-------------------------------- use rpath for GObject introspection repository

for gir in "$INK_APP_RES_DIR"/share/gir-1.0/*.gir; do
  sed "s|@executable_path/..|@rpath|g" "$gir" >"$TMP_DIR/$(basename "$gir")"
done

mv "$TMP_DIR"/*.gir "$INK_APP_RES_DIR"/share/gir-1.0

# compile *.gir into *.typelib files
for gir in "$INK_APP_RES_DIR"/share/gir-1.0/*.gir; do
  jhb run g-ir-compiler \
    -o "$INK_APP_LIB_DIR/girepository-1.0/$(basename -s .gir "$gir")".typelib \
    "$gir"
done
