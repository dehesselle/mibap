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
source "$(dirname "${BASH_SOURCE[0]}")"/src/cairosvg.sh
source "$(dirname "${BASH_SOURCE[0]}")"/src/ink.sh
source "$(dirname "${BASH_SOURCE[0]}")"/src/png2icns.sh
source "$(dirname "${BASH_SOURCE[0]}")"/src/svg2icns.sh

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

  cp "$SELF_DIR"/inkscape.bundle "$INK_BLD_DIR"
  cp "$SELF_DIR"/inkscape.plist "$INK_BLD_DIR"

  cd "$INK_BLD_DIR" || exit 1
  export ARTIFACT_DIR=$ARTIFACT_DIR   # referenced in inkscape.bundle
  jhb run gtk-mac-bundler inkscape.bundle
)

# Rename to get from lowercase "i" to capitalized "I" as the app bundle name
# depends on the main binary (and that was lowercase in 0.9x).
mv "$INK_APP_DIR" "$INK_APP_DIR".tmp   # requires case-insensitive filesysystem
mv "$INK_APP_DIR".tmp "$INK_APP_DIR"

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

# Point enchant's applespell plugin towards INK_APP_LIB_DIR using @loader_path.
lib_change_paths @loader_path/.. "$INK_APP_LIB_DIR" \
  "$INK_APP_LIB_DIR"/enchant-2/enchant_applespell.so

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
  -c "Set CFBundleShortVersionString '$(ink_get_version) \
($(ink_get_repo_shorthash))'" \
  "$INK_APP_CON_DIR"/Info.plist
/usr/libexec/PlistBuddy \
  -c "Set CFBundleVersion '$(ink_get_version) ($(ink_get_repo_shorthash))'" \
  "$INK_APP_CON_DIR"/Info.plist

# update minimum system version according to deployment target
/usr/libexec/PlistBuddy \
  -c "Set LSMinimumSystemVersion $SYS_SDK_VER" \
  "$INK_APP_CON_DIR"/Info.plist

# add some metadata to make CI identifiable
if $CI_GITLAB; then
  for var in PROJECT_NAME PROJECT_URL COMMIT_BRANCH COMMIT_SHA COMMIT_SHORT_SHA\
             JOB_ID JOB_URL JOB_NAME PIPELINE_ID PIPELINE_URL; do
    # use awk to create camel case strings (e.g. PROJECT_NAME to ProjectName)
    /usr/libexec/PlistBuddy -c "Add CI$(\
      echo $var | awk -F _ '{
        for (i=1; i<=NF; i++)
        printf "%s", toupper(substr($i,1,1)) tolower(substr($i,2))
      }'
    ) string $(eval echo \$CI_$var)" "$INK_APP_CON_DIR"/Info.plist
  done
fi

#----------------------------------------------------- generate application icon

svg2icns \
  "$INK_DIR"/share/branding/inkscape-mac.svg \
  "$INK_APP_RES_DIR"/inkscape.icns

#----------------------------------------------------------- add file type icons

cp "$INK_DIR"/packaging/macos/resources/*.icns "$INK_APP_RES_DIR"

#------------------------------------------------------- add Python and packages

# Install externally built Python framework.
ink_install_python

# Add rpath to find libraries.
lib_add_rpath @executable_path/../../../../../Resources/lib \
  "$INK_APP_FRA_DIR"/Python.framework/Versions/Current/bin/\
python"$INK_PYTHON_VER"
lib_add_rpath @executable_path/../../../../../../../../Resources/lib \
  "$INK_APP_FRA_DIR"/Python.framework/Versions/Current/Resources/\
Python.app/Contents/MacOS/Python

# Exteract the externally built wheels if present. Wheels in TMP_DIR
# will take precedence over the ones in PKG_DIR.
if [ -f "$PKG_DIR"/wheels.tar.xz ]; then
  tar -C "$TMP_DIR" -xf "$PKG_DIR"/wheels.tar.xz
else
  echo_w "not using externally built wheels"
fi

# Install wheels.
ink_pipinstall INK_PYTHON_PKG_APPDIRS         # extension manager
ink_pipinstall INK_PYTHON_PKG_BEAUTIFULSOUP4  # extension manager
ink_pipinstall INK_PYTHON_PKG_CACHECONTROL    # extension manager
ink_pipinstall INK_PYTHON_PKG_CSSSELECT
ink_pipinstall INK_PYTHON_PKG_LXML
ink_pipinstall INK_PYTHON_PKG_NUMPY
ink_pipinstall INK_PYTHON_PKG_PILLOW          # export raster extension
ink_pipinstall INK_PYTHON_PKG_PYGOBJECT
ink_pipinstall INK_PYTHON_PKG_PYSERIAL
ink_pipinstall INK_PYTHON_PKG_SCOUR

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
cp "$SELF_DIR"/fonts.conf "$INK_APP_ETC_DIR"/fonts

#-------------------------------- use rpath for GObject introspection repository

for gir in "$INK_APP_RES_DIR"/share/gir-1.0/*.gir; do
  sed "s|@executable_path/..|@rpath|g" "$gir" > "$TMP_DIR/$(basename "$gir")"
done

mv "$TMP_DIR"/*.gir "$INK_APP_RES_DIR"/share/gir-1.0

# compile *.gir into *.typelib files
for gir in "$INK_APP_RES_DIR"/share/gir-1.0/*.gir; do
  jhb run g-ir-compiler \
    -o "$INK_APP_LIB_DIR/girepository-1.0/$(basename -s .gir "$gir")".typelib \
    "$gir"
done
