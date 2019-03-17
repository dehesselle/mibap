#!/usr/bin/env bash
# 070-inkscape.sh
# https://github.com/dehesselle/mibap
#
# Compile Inkscapke.

cd $SRC_DIR
# Not using shallow clone because we cannot 'git describe' it.
#git clone --depth 1 https://gitlab.com/inkscape/inkscape
git clone https://gitlab.com/inkscape/inkscape
mkdir inkscape_build; cd inkscape_build
cmake -DCMAKE_PREFIX_PATH=$OPT_DIR -DCMAKE_INSTALL_PREFIX=$OPT_DIR -DWITH_OPENMP=OFF ../inkscape
make
make install


# patch library location before packaging

install_name_tool -change @rpath/libpoppler.85.dylib $LIB_DIR/libpoppler.85.dylib $BIN_DIR/inkscape
install_name_tool -change @rpath/libpoppler-glib.8.dylib $LIB_DIR/libpoppler-glib.8.dylib $BIN_DIR/inkscape

#

cd $SRC_DIR
git clone https://gitlab.gnome.org/GNOME/gtk-mac-bundler
cd gtk-mac-bundler
make install


#

gtk-mac-bundler inkscape.bundle


#



install_name_tool -change @rpath/libinkscape_base.dylib @executable_path/../Resources/lib/inkscape/libinkscape_base.dylib $APP_EXE_DIR/Inkscape-bin
install_name_tool -change @rpath/libpoppler.85.dylib @executable_path/../Resources/lib/libpoppler.85.dylib $APP_LIB_DIR/libpoppler-glib.8.dylib
install_name_tool -change @rpath/libpoppler.85.dylib @executable_path/../Resources/lib/libpoppler.85.dylib $APP_LIB_DIR/inkscape/libinkscape_base.dylib
install_name_tool -change @rpath/libpoppler-glib.8.dylib @executable_path/../Resources/lib/libpoppler-glib.8.dylib $APP_LIB_DIR/inkscape/libinkscape_base.dylib


# add icon

# add INKSCAPE_DATADIR setzen auf /share to launche rscript

