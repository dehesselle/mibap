#!/usr/bin/env bash
# 130-jhbuild-gtk3.sh
# https://github.com/dehesselle/mibap
#
# Install everything GTK3 required by Inkscape.

SELF_DIR=$(cd $(dirname "$0"); pwd -P)
for script in $SELF_DIR/0??-*.sh; do source $script; done

### install GTK3 libraries #####################################################

# meta-gtk-osx-freetype is included to fix a breakage in meta-gtk-osx-gtk3
# due to missing headers.
# source: <TODO - there is/was a link, but I need to find it again>

jhbuild build \
  meta-gtk-osx-bootstrap \
  meta-gtk-osx-freetype \
  meta-gtk-osx-gtk3 \
  meta-gtk-osx-gtkmm3

