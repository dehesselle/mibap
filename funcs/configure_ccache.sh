# SPDX-License-Identifier: GPL-2.0-or-later
#
# This file is part of the build pipeline for Inkscape on macOS.

### create configuration for ccache ############################################

function configure_ccache
{
  local size=$1

  mkdir -p $CCACHE_DIR

  cat <<EOF > "$CCACHE_DIR/ccache.conf"
max_size = $size
hash_dir = false
EOF
}
