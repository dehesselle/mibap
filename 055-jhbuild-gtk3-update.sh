
source 010-vars.sh
source 020-funcs.sh

### update glibmm #########

# We need to update glibmm in order to fix
# https://bugzilla.gnome.org/show_bug.cgi?id=795338

get_source $URL_GLIBMM
jhbuild run ./autogen.sh --prefix=$OPT_DIR
make_makeinstall
