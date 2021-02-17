# SPDX-License-Identifier: GPL-2.0-or-later
#
# This file is part of the build pipeline for Inkscape on macOS.

# shellcheck shell=bash # no shebang as this file is intended to be sourced
# shellcheck disable=SC2164 # we have error trapping to catch bad 'cd'

### download and extract source tarball ########################################

function install_source
{
  local url=$1
  local target_dir=$2   # optional: target directory, defaults to $SRC_DIR
  local options=$3      # optional: additional options for 'tar'

  if [ ! -d "$TMP_DIR" ]; then
    mkdir -p "$TMP_DIR"
  fi

  local log
  log=$(mktemp "$TMP_DIR"/"${FUNCNAME[0]}".XXXX)

  if [ -z "$target_dir" ]; then
    target_dir=$SRC_DIR
  fi
  if [ ! -d "$target_dir" ]; then
    mkdir -p "$target_dir"
  fi

  cd "$target_dir"

  echo "mydir = $(pwd)"

  # This downloads a file and pipes it directly into tar (file is not saved
  # to disk) to extract it. Output from stderr is saved temporarily to
  # determine the directory the files have been extracted to.
  # shellcheck disable=SC2086 # don't quote options, it can be null
  curl -L "$url" | tar xv"$(get_comp_flag "$url")" $options 2>"$log"

  local source_dir
  source_dir=$(head -1 "$log" | awk '{ print $2 }')
  if cd "$source_dir"; then
    rm "$log"
  else
    echo "${FUNCNAME[0]}: check $log"
  fi
}