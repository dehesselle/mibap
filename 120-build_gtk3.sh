#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: 2021 René de Hesselle <dehesselle@web.de>
#
# SPDX-License-Identifier: GPL-2.0-or-later

### description ################################################################

# Install GTK3 libraries and their dependencies.

### shellcheck #################################################################

# Nothing here.

### dependencies ###############################################################

source "$(dirname "${BASH_SOURCE[0]}")"/jhb/etc/jhb.conf.sh

### variables ##################################################################

SELF_DIR=$(dirname "$(greadlink -f "$0")")

### functions ##################################################################

# Nothing here.

### main #######################################################################

jhb configure "$SELF_DIR"/modulesets/inkscape.modules

cat <<EOF >> "$ETC_DIR/jhbuildrc-inkscape"
if _default_arch == "arm64":
  module_extra_env["gsl"] = { "MACOSX_DEPLOYMENT_TARGET": "" }
EOF

jhb build \
  libxml2 \
  pygments \
  python3

jhb build \
  meta-gtk-osx-bootstrap \
  meta-gtk-osx-gtk3 \
  gtkmm3
