# 060-jhbuild-inkdeps.sh
#
# Install additional dependencies into our jhbuild environment required for
# building Inkscape.

source 010-vars.sh
source 020-funcs.sh

### install gsl ################################################################

get_source $URL_GSL
configure_make_makeinstall

### install gsl ################################################################

get_source $URL_LIBPSL
jhbuild run ./autogen.sh
configure_make_makeinstall --enable-gtk-doc

### install libsoup ############################################################

# libsoup needs meson and ninja to compile and those packages require
# Python 3.
jhbuild build python3
jhbuild run pip3 install meson ninja

get_source $URL_LIBSOUP
jhbuild run meson --prefix=$OPT_DIR builddir
cd builddir
jhbuild run ninja
jhbuild run ninja install

### install Garbage Collector for C/C++ ########################################

get_source $URL_GC
configure_make_makeinstall

### install gdl ################################################################

get_source $URL_GDL
jhbuild run ./autogen.sh
configure_make_makeinstall

### install boost ##############################################################

get_source $URL_BOOST
jhbuild run ./bootstrap.sh --prefix=$OPT_DIR
jhbuild run ./b2 -j8 install

### install OpenJPEG ###########################################################

get_source $URL_OPENJPEG
mkdir builddir; cd builddir
jhbuild run cmake -DCMAKE_INSTALL_PREFIX=$OPT_DIR ..
jhbuild run make
jhbuild run make install

### install poppler ############################################################

get_source $URL_POPPLER
mkdir builddir; cd builddir
jhbuild run cmake -DCMAKE_INSTALL_PREFIX=$OPT_DIR -DENABLE_UNSTABLE_API_ABI_HEADERS=ON ..
jhbuild run make
jhbuild run make install
