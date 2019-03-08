#!/usr/bin/env bash

export MAKEFLAGS="-j8"

###

diskutil unmountDisk WORK
diskutil erasevolume HFS+ "WORK" $(hdiutil attach -nomount ram://$(expr 10 \* 1024 \* 2048))
WRK_DIR=/Volumes/WORK

###

OPT_DIR=$WRK_DIR/opt
BIN_DIR=$OPT_DIR/bin
echo "export PATH=$PATH:$BIN_DIR" > ~/.profile
source ~/.profile

TMP_DIR=$OPT_DIR/tmp
mkdir -p $TMP_DIR
SRC_DIR=$OPT_DIR/src
mkdir -p $SRC_DIR
rm -rf ~/.cache ~/.local ~/Source  # DANGER
ln -s $TMP_DIR ~/.cache
ln -s $OPT_DIR ~/.local
ln -s $SRC_DIR ~/Source

###

cd $WRK_DIR
bash <(curl -s https://gitlab.gnome.org/GNOME/gtk-osx/raw/master/gtk-osx-build-setup.sh)

# remove lines that I added in a previous run
LINE_NO=$(grep -n "# And more..." ~/.jhbuildrc-custom | awk -F ":" '{ print $1 }')
head -n +$LINE_NO ~/.jhbuildrc-custom >~/.jhbuildrc-custom.stripped
mv ~/.jhbuildrc-custom.stripped ~/.jhbuildrc-custom

mkdir -p $SRC_DIR/checkout
mkdir -p $SRC_DIR/bootstrap
mkdir -p $SRC_DIR/download

echo "checkoutroot = '$SRC_DIR/checkout'" >> ~/.jhbuildrc-custom
echo "prefix = '$OPT_DIR'" >> ~/.jhbuildrc-custom
echo "_exec_prefix = '$SRC_DIR/bootstrap'" >> ~/.jhbuildrc-custom
echo "tarballdir = '$SRC_DIR/download'" >> ~/.jhbuildrc-custom
echo "quiet_mode = True" >> ~/.jhbuildrc-custom
echo "progress_bar = True" >> ~/.jhbuildrc-custom

###

jhbuild bootstrap
read -p "*** PRESS ENTER TO CONTINUE ***"

###

cd $SRC_DIR
curl ftp://xmlsoft.org/libxml2/libxml2-2.9.9.tar.gz | tar xz
cd libxml2-2.9.9
jhbuild run ./configure --prefix=$OPT_DIR --with-python-install-dir=$OPT_DIR/lib/python2.7/site-packages
jhbuild run make
jhbuild run make install
read -p "*** PRESS ENTER TO CONTINUE ***"

###

jhbuild build meta-gtk-osx-bootstrap
jhbuild build meta-gtk-osx-gtk3
jhbuild build vala gtkmm3
read -p "*** PRESS ENTER TO CONTINUE ***"

###

cd $SRC_DIR
curl http://ftp.fau.de/gnu/gsl/gsl-2.5.tar.gz | tar xz
cd gsl-2.5
jhbuild run ./configure --prefix=$OPT_DIR
jhbuild run make
jhbuild run make install
read -p "*** PRESS ENTER TO CONTINUE ***"
###

cd $SRC_DIR
git clone https://github.com/rockdaboot/libpsl
cd libpsl
git checkout libpsl-0.20.2
jhbuild run ./autogen.sh
jhbuild run ./configure --enable-gtk-doc --prefix=$OPT_DIR
jhbuild run make
jhbuild run make install
read -p "*** PRESS ENTER TO CONTINUE ***"
###

jhbuild build python3   # separate command *AFTER* the other ones on purpose!
jhbuild run pip3 install meson ninja
read -p "*** PRESS ENTER TO CONTINUE ***"
###

cd $SRC_DIR

curl https://ftp.gnome.org/pub/GNOME/sources/libsoup/2.65/libsoup-2.65.92.tar.xz | tar xJ
cd libsoup-2.65.92
jhbuild run meson --prefix=$OPT_DIR builddir
cd builddir
jhbuild run ninja
jhbuild run ninja install
read -p "*** PRESS ENTER TO CONTINUE ***"
###

cd $SRC_DIR
curl http://www.hboehm.info/gc/gc_source/gc-8.0.2.tar.gz | tar xz
cd gc-8.0.2
jhbuild run ./configure --prefix=$OPT_DIR
jhbuild run make
jhbuild run make install
read -p "*** PRESS ENTER TO CONTINUE ***"
###

cd $SRC_DIR
git clone https://gitlab.gnome.org/GNOME/gdl/
cd gdl
git checkout GDL_3_28_0
jhbuild run ./autogen.sh
jhbuild run ./configure --prefix=$OPT_DIR
jhbuild run make
jhbuild run make install
read -p "*** PRESS ENTER TO CONTINUE ***"
###

cd $SRC_DIR
curl -L https://dl.bintray.com/boostorg/release/1.69.0/source/boost_1_69_0.tar.bz2 | tar xj
cd boost_1_69_0
jhbuild run ./bootstrap.sh --prefix=$OPT_DIR
jhbuild run ./b2 -j8 install
read -p "*** PRESS ENTER TO CONTINUE ***"
###

cd $SRC_DIR
curl -L https://github.com/uclouvain/openjpeg/archive/v2.3.0.tar.gz | tar xz
cd openjpeg-2.3.0
mkdir builddir; cd builddir
jhbuild run cmake -DCMAKE_INSTALL_PREFIX=$OPT_DIR ..
jhbuild run make
jhbuild run make install

cd $SRC_DIR
curl https://poppler.freedesktop.org/poppler-0.74.0.tar.xz | tar xJ
cd poppler-0.74.0
mkdir builddir; cd builddir
jhbuild run cmake -DCMAKE_INSTALL_PREFIX=$OPT_DIR -DENABLE_UNSTABLE_API_ABI_HEADERS=ON ..
jhbuild run make
jhbuild run make install

read -p "*** PRESS ENTER TO CONTINUE ***"

cd $SRC_DIR
git clone --depth 1 https://gitlab.com/inkscape/inkscape
mkdir inkscape_build; cd inkscape_build
cmake -DCMAKE_PREFIX_PATH=$OPT -DCMAKE_INSTALL_PREFIX=$WRK_DIR/inkscape -DWITH_OPENMP=OFF ../inkscape



