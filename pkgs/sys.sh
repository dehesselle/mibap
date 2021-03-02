# SPDX-License-Identifier: GPL-2.0-or-later

### description ################################################################

# TODO: blabla

### settings ###################################################################

# shellcheck shell=bash # no shebang as this file is intended to be sourced
# shellcheck disable=SC2034 # no exports desired

### variables ##################################################################

SYS_SDK_VER=$(/usr/libexec/PlistBuddy -c "Print \
:DefaultProperties:MACOSX_DEPLOYMENT_TARGET" "$SDKROOT"/SDKSettings.plist)
SYS_SDK_VER_RECOMMENDED=10.11

SYS_XCODE_VER=$(xcodebuild -version | grep Xcode | awk '{ print $2 }')
SYS_XCODE_VER_RECOMMENDED=12.4

SYS_MACOS_VER=$(sw_vers -productVersion)
SYS_MACOS_VER_RECOMMENDED=10.15.7

# The Python 3 version supplied by the system (technically: Xcode) will be used
# to run JHBuild and Meson, as these two are installed before we build
# Python ourselves. There is no need to use "latest and greatest" here.
SYS_PYTHON_VER=$(python3 -c \
  "import sys; print('{0[0]}.{0[1]}'.format(sys.version_info))")
SYS_PYTHON_VER_RECOMMENDED=3.8

### functions ##################################################################

function sys_check_recommendations
{
  if [ "$SYS_SDK_VER" != "$SYS_SDK_VER_RECOMMENDED" ]; then
    echo_w "recommended    SDK version: $SYS_SDK_VER_RECOMMENDED"
    echo_w "       your    SDK version: $SYS_SDK_VER"
  fi

  if [ "$SYS_XCODE_VER" != "$SYS_XCODE_VER_RECOMMENDED" ]; then
    echo_w "recommended  Xcode version: $SYS_XCODE_VER_RECOMMENDED"
    echo_w "       your  Xcode version: $SYS_XCODE_VER"
  fi

  if [ "$SYS_MACOS_VER" != "$SYS_MACOS_VER_RECOMMENDED" ]; then
    echo_w "recommended  macOS version: $SYS_MACOS_VER_RECOMMENDED"
    echo_w "       your  macOS version: $SYS_MACOS_VER"
  fi

  if [ "$SYS_PYTHON_VER" != "$SYS_PYTHON_VER_RECOMMENDED" ]; then
    echo_w "recommended Python version: $SYS_PYTHON_VER_RECOMMENDED"
    echo_w "       your Python version: $SYS_PYTHON_VER"
  fi
}
