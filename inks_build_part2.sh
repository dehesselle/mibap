#!/usr/bin/env bash

export MAKEFLAGS="-j8"

###
WRK_DIR=/Volumes/WORK
OPT_DIR=$WRK_DIR/opt
BIN_DIR=$OPT_DIR/bin
TMP_DIR=$OPT_DIR/tmp
SRC_DIR=$OPT_DIR/src

###
###
###

cd $SRC_DIR
curl http://ftp.fau.de/gnu/gsl/gsl-2.5.tar.gz | tar xz
cd gsl-2.5
jhbuild run ./configure --prefix=$OPT_DIR
jhbuild run make
jhbuild run make install

###

cd $SRC_DIR
git clone https://github.com/rockdaboot/libpsl
cd libpsl
git checkout libpsl-0.20.2
jhbuild run ./autogen.sh
jhbuild run ./configure --enable-gtk-doc --prefix=$OPT_DIR
jhbuild run make
jhbuild run make install

###

jhbuild build python3   # separate command *AFTER* the other ones on purpose!
jhbuild run pip3 install meson ninja

###

cd $SRC_DIR

curl https://ftp.gnome.org/pub/GNOME/sources/libsoup/2.65/libsoup-2.65.92.tar.xz | tar xJ
cd libsoup-2.65.92
jhbuild run meson --prefix=$OPT_DIR builddir
cd builddir
jhbuild run ninja
jhbuild run ninja install

###

cd $SRC_DIR
curl http://www.hboehm.info/gc/gc_source/gc-8.0.2.tar.gz | tar xz
cd gc-8.0.2
jhbuild run ./configure --prefix=$OPT_DIR
jhbuild run make
jhbuild run make install

###

cd $SRC_DIR
git clone https://gitlab.gnome.org/GNOME/gdl/
cd gdl
git checkout GDL_3_28_0
jhbuild run ./autogen.sh
jhbuild run ./configure --prefix=$OPT_DIR
jhbuild run make
jhbuild run make install

###

cd $SRC_DIR
curl -L https://dl.bintray.com/boostorg/release/1.69.0/source/boost_1_69_0.tar.bz2 | tar xj
cd boost_1_69_0
jhbuild run ./bootstrap.sh --prefix=$OPT_DIR
jhbuild run ./b2 -j8 install

###

cd $SRC_DIR
curl -L https://github.com/uclouvain/openjpeg/archive/v2.3.0.tar.gz | tar xz
cd openjpeg-2.3.0
mkdir builddir; cd builddir
jhbuild run cmake -DCMAKE_INSTALL_PREFIX=$OPT_DIR ..
jhbuild run make
jhbuild run make install

###

cd $SRC_DIR
curl https://poppler.freedesktop.org/poppler-0.74.0.tar.xz | tar xJ
cd poppler-0.74.0
mkdir builddir; cd builddir
jhbuild run cmake -DCMAKE_INSTALL_PREFIX=$OPT_DIR -DENABLE_UNSTABLE_API_ABI_HEADERS=ON ..
jhbuild run make
jhbuild run make install

###

cd $SRC_DIR
curl -L https://github.com/GNOME/glibmm/archive/2.56.1.tar.gz | tar xz
cd glibmm-2.56.1
jhbuild run ./autogen.sh --prefix=$OPT_DIR
jhbuild run make
jhbuild run make install

###

cd $SRC_DIR
git clone --depth 1 https://gitlab.com/inkscape/inkscape
mkdir inkscape_build; cd inkscape_build
cmake -DCMAKE_PREFIX_PATH=$OPT_DIR -DCMAKE_INSTALL_PREFIX=$OPT_DIR/inkscape -DWITH_OPENMP=OFF ../inkscape
make
make install


exit 0 

### need to patch libraries in binary

install_name_tool -change @rpath/libpoppler.85.dylib $OPT_DIR/lib/libpoppler.85.dylib $OPT_DIR/bin/inkscape
install_name_tool -change @rpath/libpoppler-glib.8.dylib $OPT_DIR/lib/libpoppler-glib.8.dylib $OPT_DIR/bin/inkscape


### after packaging

APP_DIR=/Users/rene/Desktop/Inkscape.app

install_name_tool -change @rpath/libinkscape_base.dylib @executable_path/../Resources/lib/inkscape/libinkscape_base.dylib $APP_DIR/Contents/MacOS/Inkscape-bin
install_name_tool -change @rpath/libpoppler.85.dylib @executable_path/../Resources/lib/libpoppler.85.dylib $APP_DIR/Contents/Resources/lib/libpoppler-glib.8.dylib
install_name_tool -change @rpath/libpoppler.85.dylib @executable_path/../Resources/lib/libpoppler.85.dylib $APP_DIR/Contents/Resources/lib/inkscape/libinkscape_base.dylib
install_name_tool -change @rpath/libpoppler-glib.8.dylib @executable_path/../Resources/lib/libpoppler-glib.8.dylib $APP_DIR/Contents/Resources/lib/inkscape/libinkscape_base.dylib


launcher-script anpassen:

INKSCAPE_DATADIR setzen auf /share


####

# not required
#cd $SRC_DIR
#curl -L https://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.15.tar.gz | tar xz
#cd libiconv-1.15
#jhbuild run ./configure --prefix=$OPT_DIR
#jhbuild run make
#jhbuild run make install


cd $SRC_DIR
curl -L https://ftp.pcre.org/pub/pcre/pcre-8.43.tar.gz | tar xz
cd pcre-8.43
jhbuild run ./configure --prefix=$OPT_DIR --enable-utf
jhbuild run make
jhbuild run make install


cd $SRC_DIR
curl -L https://download.gnome.org/sources/glib/2.60/glib-2.60.0.tar.xz | tar xJ
cd glib-2.60.0
jhbuild run meson _build -Diconv=native --prefix=$OPT_DIR
jhbuild run ninja -C _build 
jhbuild run ninja -C _build install 






cd $SRC_DIR
curl -L https://download.gnome.org/sources/libsigc++/2.99/libsigc++-2.99.12.tar.xz | tar xJ
cd libsigc++-2.99.12
jhbuild run ./autogen.sh
jhbuild run ./configure --prefix=$OPT_DIR
jhbuild run make
jhbuild run make install




######################## glibmm fails to build!!!!!!


cd $SRC_DIR
curl -L https://github.com/GNOME/mm-common/archive/0.9.12.tar.gz | tar xz
cd mm-common-0.9.12
jhbuild run ./autogen.sh
jhbuild run ./configure --prefix=$OPT_DIR
jhbuild run make USE_NETWORK=yes
jhbuild run make install



cd $SRC_DIR
curl -L https://github.com/GNOME/glibmm/archive/2.59.1.tar.gz | tar xz
cd glibmm-2.59.1
jhbuild run ./autogen.sh
jhbuild run ./configure --prefix=$OPT_DIR




cd $SRC_DIR
curl -L https://github.com/GNOME/glibmm/archive/2.51.5.tar.gz | tar xz
cd glibmm-2.51.5
jhbuild run ./autogen.sh --prefix=$OPT_DIR
jhbuild run make
jhbuild run make install



cd $SRC_DIR
curl -L https://github.com/GNOME/glibmm/archive/2.56.1.tar.gz | tar xz
cd glibmm-2.56.1
jhbuild run ./autogen.sh --prefix=$OPT_DIR
jhbuild run make
jhbuild run make install




