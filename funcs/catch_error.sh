# SPDX-License-Identifier: GPL-2.0-or-later
#
# This file is part of the build pipeline for Inkscape on macOS.

### this function is called on "trap ERR" ###################################### 

# macOS' old bash 3.x has a bug that causes the line number of the error
# to point to the function entry instead of the command inside the function.

function catch_error
{
  local file=$1
  local line=$2
  local func=$3
  local command=$4
  local rc=$5

  [ -z $func ] && func="main" || true

  ((ERRTRACE_COUNT++))

  case $ERRTRACE_COUNT in
    1) echo -e "\033[97m\033[101m\033[1m[$file:$line] $func failed with rc=$rc\033[39m\033[49m\033[0m"
       echo -e "\033[93m$command\033[39m"
       ;;
    *) echo -e "[$file:$line] <- $func"
       ;;
  esac
}