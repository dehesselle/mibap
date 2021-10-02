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

# shellcheck disable=SC1090 # can't point to a single source here
for script in "$(dirname "${BASH_SOURCE[0]}")"/0??-*.sh; do
  source "$script";
done

### variables ##################################################################

# Nothing here.

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
  jhbuild run gtk-mac-bundler inkscape.bundle
)

# Rename to get from lowercase to capitalized "i" as the binary was completely
# lowercase in the 0.9x versions.
# (Doing it this way works only on case-insensitive filesystems.)
mv "$INK_APP_DIR" "$INK_APP_DIR".tmp
mv "$INK_APP_DIR".tmp "$INK_APP_DIR"

#------------------------------------------------------ patch library link paths

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

svg2icns "$INK_DIR"/share/branding/inkscape-mac.svg \
         "$INK_APP_RES_DIR"/inkscape.icns

#----------------------------------------------------------- add file type icons

cp "$INK_DIR"/packaging/macos/resources/*.icns "$INK_APP_RES_DIR"

#------------------------------------------------------- add Python and packages

# Install externally built Python framework.
ink_install_python

# Exteract the externally built wheels (if present).
if [ -f "$INK_WHEELS_DIR"/wheels.tar.xz ]; then
  tar -C "$TMP_DIR" -xf "$INK_WHEELS_DIR"/wheels.tar.xz
  INK_WHEELS_DIR=$TMP_DIR
else
  echo_w "not using externally built wheels"
fi

# Install wheels.
ink_pipinstall_cssselect
ink_pipinstall_lxml
ink_pipinstall_numpy
ink_pipinstall_pygobject
ink_pipinstall_pyserial
ink_pipinstall_scour
ink_pipinstall_urllib3

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

#--------------------------------------- modify GObject introspection repository

# change paths to match Python binary, not Inkscape binary
for gir in "$INK_APP_RES_DIR"/share/gir-1.0/*.gir; do
  sed "s/\
@executable_path/\
$(sed_escape_str @executable_path/../../../..)/g" "$gir" > \
    "$TMP_DIR/$(basename "$gir")"
done

mv "$TMP_DIR"/*.gir "$INK_APP_RES_DIR"/share/gir-1.0

# compile *.gir into *.typelib files
for gir in "$INK_APP_RES_DIR"/share/gir-1.0/*.gir; do
  jhbuild run g-ir-compiler \
    -o "$INK_APP_LIB_DIR/girepository-1.0/$(basename -s .gir "$gir")".typelib \
    "$gir"
done
