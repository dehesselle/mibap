#!/usr/bin/env bash
# 050-jhbuild-gtk3.sh
# https://github.com/dehesselle/mibap
#
# Install everything GTK3 required by Inkscape.

SELF_DIR=$(cd $(dirname "$0"); pwd -P)
source $SELF_DIR/010-vars.sh
source $SELF_DIR/020-funcs.sh

### install GTK3 libraries #####################################################

jhbuild build \
  gtkmm3 \
  meta-gtk-osx-bootstrap \
  meta-gtk-osx-freetype \
  meta-gtk-osx-gtk3

### update C++ bindings for Glib ###############################################

# We need to update glibmm in order to fix
# https://bugzilla.gnome.org/show_bug.cgi?id=795338

get_source $URL_GLIBMM
jhbuild run ./autogen.sh --prefix=$OPT_DIR
make_makeinstall
