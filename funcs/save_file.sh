# SPDX-License-Identifier: GPL-2.0-or-later
#
# This file is part of the build pipeline for Inkscape on macOS.

### download a file and save to disk ###########################################

function save_file
{
  local url=$1
  local target_dir=$2   # optional argument, defaults to $SRC_DIR

  [ -z $target_dir ] && target_dir=$SRC_DIR

  local file=$target_dir/$(basename $url)
  if [ -f $file ]; then
    echo "$FUNCNAME: file $file exists"
  else
    curl -o $file -L $url
  fi
}