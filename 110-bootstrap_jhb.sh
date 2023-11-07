#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: 2022 René de Hesselle <dehesselle@web.de>
#
# SPDX-License-Identifier: GPL-2.0-or-later

### description ################################################################

# Bootstrap jhb with our slightly customized configuration. We use our own
# versioning and naming scheme, making this incompatible with the pre-built
# bootstrapped jhb archive (everything will be built from scratch here).

### shellcheck #################################################################

# Nothing here.

### dependencies ###############################################################

#------------------------------------------------------ source jhb configuration

source "$(dirname "${BASH_SOURCE[0]}")"/jhb/etc/jhb.conf.sh

### variables ##################################################################

SELF_DIR=$(dirname "${BASH_SOURCE[0]}")

PACKAGE_CACHE_DIR=${PACKAGE_CACHE_DIR:-""}

### functions ##################################################################

function preload
{
  local source_dir=$1

  source "$SELF_DIR/jhb/etc/jhb.conf.sh"
  mkdir -p "$PKG_DIR"

  echo "using PACKAGE_CACHE_DIR=$PACKAGE_CACHE_DIR"

  local xp_elements="*[self::autotools or self::cmake or self::distutils or \
self::meson]"

  # Iterate over every module in every moduleset and check if the file is
  # available in source_dir. If it is, copy it to PKG_DIR.
  for modules in "$SELF_DIR"/jhb/etc/modulesets/jhb/*.modules \
                 "$SELF_DIR"/modulesets/*.modules; do
    local count
    count=$(xmllint --xpath "count(//moduleset/$xp_elements)" "$modules")
    local i=1
    while [ $i -le "$count" ]; do
      local package
      # shellcheck disable=SC1087 # this is no array expansion
      package=$(xmllint --xpath "string(//moduleset/\
$xp_elements[$i]/branch/@rename-tarball)" "$modules")
      if [ -z "$package" ]; then
        # shellcheck disable=SC1087 # this is no array expansion
        package=$(xmllint --xpath "string(//moduleset/\
$xp_elements[$i]/branch/@module)" "$modules")
      fi

      package=$source_dir/$(basename "$package")
      if [ -f "$package" ]; then
        cp "$package" "$PKG_DIR"
      fi
      ((i++))
    done
  done
}

### main #######################################################################

if [ -d "$PACKAGE_CACHE_DIR" ]; then
  preload "$PACKAGE_CACHE_DIR"
fi

mkdir -p "$ETC_DIR"/modulesets/jhb
cp "$SELF_DIR"/modulesets/jhbuildrc.jhb "$ETC_DIR"/modulesets/jhb/jhbuildrc

"$SELF_DIR"/jhb/usr/bin/bootstrap
