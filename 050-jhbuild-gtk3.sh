# 050-jhbuild-gtk3.sh
#
# Install everything GTK3 required by Inkscape.

source 010-vars.sh
source 020-funcs.sh

### install GTK3 ###############################################################

jhbuild build meta-gtk-osx-bootstrap meta-gtk-osx-gtk3 gtkmm3 vala

### update C++ bindings for Glib ###############################################

# We need to update glibmm in order to fix
# https://bugzilla.gnome.org/show_bug.cgi?id=795338

get_source $URL_GLIBMM
jhbuild run ./autogen.sh --prefix=$OPT_DIR
make_makeinstall
