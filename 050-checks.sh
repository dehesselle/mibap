# SPDX-License-Identifier: GPL-2.0-or-later
#
# This file is part of the build pipeline for Inkscape on macOS.
#
# ### 050-checks.sh ###
# Check basic prerequisites and break if they're not met.

### settings ###################################################################

# shellcheck shell=bash # no shebang as this file is intended to be sourced

### main #######################################################################

#---------------------------------------------------- check if WRK_DIR is usable

# shellcheck disable=SC2046 # result is integer
if  [ $(mkdir -p "$WRK_DIR" 2>/dev/null; echo $?) -eq 0 ] &&
    [ -w "$WRK_DIR" ] ; then
  : # WRK_DIR has been created or was already there and is writable
else
  echo_e "WRK_DIR not usable: $WRK_DIR"
  exit 1
fi

#----------------------------------------------------- check for presence of SDK

if [ ! -d "$SDKROOT" ]; then
  echo_e "SDK not found: $SDKROOT"
  exit 1
fi

#------------------------------------------------- check version recommendations

sys_check_recommendations