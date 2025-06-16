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

### variables ##################################################################

SELF_DIR=$(dirname "$(greadlink -f "$0")")

### functions ##################################################################

# Nothing here.

### main #######################################################################

error_trace_enable

#----------------------------------------------------- generate application icon

svg2icns \
  "$INK_DIR"/share/branding/inkscape-mac.svg \
  "$TMP_DIR"/Inkscape.icns

#----------------------------------------------------- create application bundle

tar -C "$TMP_DIR" -xJf "$PKG_DIR/$(basename "${INK_PYTHON_URL}")"

abcreate create -s "$VER_DIR" -t "$ART_DIR" \
    "$SELF_DIR"/resources/applicationbundle.xml

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

#----------------------------------------------------------- add file type icons

cp "$INK_DIR"/packaging/macos/res/*.icns "$INK_APP_RES_DIR"

#----------------------------------------------------------- add Python packages

# add .pth file and icon
ink_configure_python

# Add rpath to find libraries.
lib_add_rpath @executable_path/../../../../../Frameworks \
  "$INK_APP_FRA_DIR/Python.framework/Versions/Current/bin/python$INK_PYTHON_VER"
lib_add_rpath @executable_path/../../../../../../../../Frameworks \
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
