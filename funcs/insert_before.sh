# SPDX-License-Identifier: GPL-2.0-or-later
#
# This file is part of the build pipeline for Inkscape on macOS.

### insert line into a textfile ################################################

# usage:
# insert_before <filename> <insert before this pattern> <line to insert>

function insert_before
{
  local file=$1
  local pattern=$2
  local line=$3

  local file_tmp=$(mktemp)
  awk "/${pattern}/{print \"$line\"}1" $file > $file_tmp
  cat $file_tmp > $file   # we don't 'mv' to preserve permissions
  rm $file_tmp
}