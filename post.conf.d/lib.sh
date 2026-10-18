# SPDX-FileCopyrightText: 2021 René de Hesselle <dehesselle@web.de>
#
# SPDX-License-Identifier: GPL-2.0-or-later

### description ################################################################

# Provide convenience wrappers for install_name_tool.
#
# This code was once part of jhb and got removed once abcreate took over
# application bundle duties. However, dealing with pip installs isn't handled
# there yet, so we still depend on that code here.

### shellcheck #################################################################

# shellcheck shell=bash # no shebang as this file is intended to be sourced

### variables ##################################################################

# Nothing here.

### functions ##################################################################

function lib_change_path
{
  # Compared to install_name_tool, this function
  #   - requires less arguments as 'source' can be deducted from 'target'
  #   - can apply the requested changes to multiple binaries at once

  local target=$1         # new path to dynamically linked library
  local binaries=${*:2}   # binaries to modify

  local source_lib=${target##*/}   # get library filename from target location

  for binary in $binaries; do   # won't work if spaces in paths
    local source=$(otool -L $binary | grep "$source_lib " | awk '{ print $1 }')
    if [ -z $source ]; then
      echo_w "no $source_lib in $binary"
    else
      # Reconstructing 'target' as it might have been specified as regex.
      target=$(dirname $target)/$(basename $source)

      install_name_tool -change $source $target $binary
    fi
  done
}

function lib_change_paths
{
  # This is a wrapper ontop lib_change_path: given a directory 'lib_dir' that
  # contains the libraries, all (matching) libraries linked in 'binary' can be
  # changed at once to a specified 'target' path.

  local target=$1         # new path to dynamically linked library
  local lib_dir=$2
  local binaries=${*:3}

  for binary in $binaries; do
    for linked_lib in $(otool -L $binary | tail -n +2 | awk '{ print $1 }'); do
      if [ "$(basename $binary)" != "$(basename $linked_lib)" ] &&
         [ -f $lib_dir/$(basename $linked_lib) ]; then
        lib_change_path $target/$(basename $linked_lib) $binary
      fi
    done
  done
}

### main #######################################################################

# Nothing here.
