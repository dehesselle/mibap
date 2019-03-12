#!/usr/bin/env bash

export MAKEFLAGS="-j8"

###

diskutil unmountDisk WORK
diskutil erasevolume HFS+ "WORK" $(hdiutil attach -nomount ram://$(expr 5 \* 1024 \* 2048))
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

###

cd $SRC_DIR
curl ftp://xmlsoft.org/libxml2/libxml2-2.9.9.tar.gz | tar xz
cd libxml2-2.9.9
jhbuild run ./configure --prefix=$OPT_DIR --with-python-install-dir=$OPT_DIR/lib/python2.7/site-packages
jhbuild run make
jhbuild run make install

###

jhbuild build meta-gtk-osx-bootstrap
jhbuild build meta-gtk-osx-gtk3
jhbuild build vala gtkmm3

###

cd $SRC_DIR
git clone https://gitlab.gnome.org/GNOME/gtk-mac-bundler
cd gtk-mac-bundler
make install

###

cd


