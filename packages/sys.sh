# SPDX-FileCopyrightText: 2021 René de Hesselle <dehesselle@web.de>
#
# SPDX-License-Identifier: GPL-2.0-or-later

### description ################################################################

# System related things like checking versions of macOS and Xcode.

### shellcheck #################################################################

# shellcheck shell=bash # no shebang as this file is intended to be sourced

### dependencies ###############################################################

# Nothing here.

### variables ##################################################################

SYS_MACOS_VER=$(sw_vers -productVersion)
SYS_MACOS_VER_RECOMMENDED=10.15.7

SYS_SDK_VER=$(/usr/libexec/PlistBuddy -c "Print \
:DefaultProperties:MACOSX_DEPLOYMENT_TARGET" "$SDKROOT"/SDKSettings.plist)
SYS_SDK_VER_RECOMMENDED=10.13

SYS_XCODE_VER=$( (xcodebuild -version 2>/dev/null || echo "Xcode n/a") | grep Xcode | awk '{ print $2 }')
SYS_XCODE_VER_RECOMMENDED=12.4

if [ "$SYS_IGNORE_USR_LOCAL" != "true" ]; then
  SYS_IGNORE_USR_LOCAL=false
fi

### functions ##################################################################

function sys_check_versions
{
  # Check version recommendations.

  if [ "$SYS_SDK_VER" != "$SYS_SDK_VER_RECOMMENDED" ]; then
    echo_w "recommended   SDK: $(printf '%8s' $SYS_SDK_VER_RECOMMENDED)"
    echo_w "       your   SDK: $(printf '%8s' "$SYS_SDK_VER")"
  fi

  if [ "$SYS_XCODE_VER" != "$SYS_XCODE_VER_RECOMMENDED" ]; then
    echo_w "recommended Xcode: $(printf '%8s' $SYS_XCODE_VER_RECOMMENDED)"
    echo_w "       your Xcode: $(printf '%8s' "$SYS_XCODE_VER")"
  fi

  if [ "$SYS_MACOS_VER" != "$SYS_MACOS_VER_RECOMMENDED" ]; then
    echo_w "recommended macOS: $(printf '%8s' $SYS_MACOS_VER_RECOMMENDED)"
    echo_w "       your macOS: $(printf '%8s' "$SYS_MACOS_VER")"
  fi
}

function sys_create_log
{
  # Create release.log file.

  mkdir -p "$VAR_DIR"/log

  for var in SYS_MACOS_VER SYS_SDK_VER SYS_XCODE_VER VERSION WRK_DIR; do
    echo "$var = $(eval echo \$$var)" >> "$VAR_DIR"/log/release.log
  done
}

function sys_check_wrkdir
{
  # shellcheck disable=SC2046 # result is integer
  if  [ $(mkdir -p "$WRK_DIR" 2>/dev/null; echo $?) -eq 0 ] &&
      [ -w "$WRK_DIR" ] ; then
    : # WRK_DIR has been created or was already there and is writable
  else
    echo_e "WRK_DIR not usable: $WRK_DIR"
    return 1
  fi
}

function sys_check_sdkroot
{
  if [ ! -d "$SDKROOT" ]; then
    echo_e "SDK not found: $SDKROOT"
    return 1
  fi
}

function sys_check_usr_local
{
  local count=0

  # Taken from GitHub CI experience, it appears to be enough to make sure
  # the following folders do not contain files.
  for dir in include lib share; do
    count=$(( count + \
      $(find /usr/local/$dir -type f 2>/dev/null | wc -l | awk '{ print $1 }')\
    ))
  done

  if [ "$count" -ne 0 ]; then
    if $SYS_IGNORE_USR_LOCAL; then
      echo_w "Found files in '/usr/local/[include|lib|share]'."
      echo_w "You chose to continue anyway, good luck!        "
    else
      echo_e "Found files in '/usr/local/[include|lib|share]. Will not continue"
      echo_e "as this is an unsupported configuraiton, known to cause trouble. "
      echo_e "However, you can use                                             "
      echo_e "                                                                 "
      echo_e "    export SYS_IGNORE_USR_LOCAL=true                             "
      echo_e "                                                                 "
      echo_e "to ignore this error at your own risk.                           "
      return 1
    fi
  fi
}

### main #######################################################################

# Nothing here.