# SPDX-FileCopyrightText: 2021 René de Hesselle <dehesselle@web.de>
#
# SPDX-License-Identifier: GPL-2.0-or-later

### description ################################################################

# dmgbuild is a Python package that simplifies the process of creating a
# disk image (dmg) for distribution.

### shellcheck #################################################################

# shellcheck shell=bash # no shebang as this file is intended to be sourced

### dependencies ###############################################################

# Nothing here.

### variables ##################################################################

# https://dmgbuild.readthedocs.io/en/latest/
# https://github.com/al45tair/dmgbuild
# including optional dependencies:
# - biplist: binary plist parser/generator
# - pyobjc-*: framework wrappers
DMGBUILD_PIP="\
  biplist==1.0.3\
  dmgbuild==1.5.2\
  ds-store==1.3.0\
  mac-alias==2.2.0\
  pyobjc-core==7.3\
  pyobjc-framework-Cocoa==7.3\
  pyobjc-framework-Quartz==7.3\
"

DMGBUILD_CONFIG="$SRC_DIR"/inkscape_dmg.py

### functions ##################################################################

function dmgbuild_install
{
  # shellcheck disable=SC2086 # we need word splitting here
  jhb run $JHBUILD_PYTHON_PIP install \
    --prefix $USR_DIR --ignore-installed $DMGBUILD_PIP

  # dmgbuild has issues with detaching, workaround is to increase max retries
  sed -i '' '$ s/HiDPI)/HiDPI, detach_retries=15)/g' "$USR_DIR"/bin/dmgbuild
}

function dmgbuild_run
{
  local dmg_file=$1

  # Copy templated version of the file (it contains placeholders) to source
  # directory. They copy will be modified to contain the actual values.
  cp "$SELF_DIR"/"$(basename "$DMGBUILD_CONFIG")" "$SRC_DIR"

  # set application
  sed -i '' "s|PLACEHOLDERAPPLICATION|$INK_APP_DIR|" "$DMGBUILD_CONFIG"

  # set disk image icon (if it exists)
  local icon
  icon=$SRC_DIR/$(basename -s .py "$DMGBUILD_CONFIG").icns
  if [ -f "$icon" ]; then
    sed -i '' "s|PLACEHOLDERICON|$icon|" "$DMGBUILD_CONFIG"
  fi

  # set background image (if it exists)
  local background
  background=$SRC_DIR/$(basename -s .py "$DMGBUILD_CONFIG").png
  if [ -f "$background" ]; then
    sed -i '' "s|PLACEHOLDERBACKGROUND|$background|" "$DMGBUILD_CONFIG"
  fi

  # Create disk image in temporary location and move to target location
  # afterwards. This way we can run multiple times without requiring cleanup.
  dmgbuild -s "$DMGBUILD_CONFIG" "$(basename -s .app "$INK_APP_DIR")" "$TMP_DIR"/"$(basename "$dmg_file")"
  mv "$TMP_DIR"/"$(basename "$dmg_file")" "$dmg_file"
}

### main #######################################################################

# Nothing here.