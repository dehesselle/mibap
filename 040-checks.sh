# SPDX-License-Identifier: GPL-2.0-or-later
#
# This file is part of the build pipeline for Inkscape on macOS.
#
# ### 040-checks.sh ###
# Check basic prerequisites and break if they're not met.

[ -z $CHECKS_INCLUDED ] && CHECKS_INCLUDED=true || return   # include guard

### check if WRK_DIR is usable #################################################

if  [ $(mkdir -p $WRK_DIR 2>/dev/null; echo $?) -eq 0 ] &&
    [ -w $WRK_DIR ] ; then
  : # WRK_DIR has been created or was already there and is writable
else
  echo_e "WRK_DIR not usable: $WRK_DIR"
  exit 1
fi

### check for presence of SDK ##################################################

if [ ! -d $SDKROOT ]; then
  echo_e "SDK not found: $SDKROOT"
  exit 1
fi

### check SDK version ##########################################################

if [ "$SDK_VER" != "$SDK_VER_RECOMMENDED" ]; then
  echo_w "recommended   SDK version: $SDK_VER_RECOMMENDED"
  echo_w "       your   SDK version: $SDK_VER"
fi

### check Xcode version ########################################################

if [ "$XCODE_VER" != "$XCODE_VER_RECOMMENDED" ]; then
  echo_w "recommended Xcode version: $XCODE_VER_RECOMMENDED"
  echo_w "       your Xcode version: $XCODE_VER"
fi

### check macOS version ########################################################

if [ "$MACOS_VER" != "$MACOS_VER_RECOMMENDED" ]; then
  echo_w "recommended macOS version: $MACOS_VER_RECOMMENDED"
  echo_w "       your macOS version: $MACOS_VER"
fi
