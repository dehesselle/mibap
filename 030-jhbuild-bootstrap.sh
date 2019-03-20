#!/usr/bin/env bash
# 030-jhbuild-bootstrap.sh
# https://github.com/dehesselle/mibap
#
# Bootstrap the jhbuild environment.

SELF_DIR=$(cd $(dirname "$0"); pwd -P)
source $SELF_DIR/010-vars.sh

### create ramdisk as workspace ################################################

diskutil eject "$WRK_DIR"
diskutil erasevolume HFS+ "$RAMDISK" $(hdiutil attach -nomount ram://$(expr $RAMDISK_SIZE \* 1024 \* 2048))

### setup path #################################################################

echo "export PATH=$BIN_DIR:/usr/bin:/bin:/usr/sbin:/sbin" > ~/.profile
source ~/.profile

### setup directories for jhbuild ##############################################

mkdir -p $TMP_DIR
mkdir -p $SRC_DIR/checkout     # extracted tarballs
mkdir -p $SRC_DIR/bootstrap
mkdir -p $SRC_DIR/download     # downloaded tarballs

# DANGER: Operations like this are the reason that you're supposed to use
# a dedicated machine for building. This script does not care for your
# data.
rm -rf ~/.cache ~/.local ~/Source   # remove remnants of previous run
ln -sf $TMP_DIR ~/.cache   # link to our workspace
ln -sf $OPT_DIR ~/.local   # link to our workspace
ln -sf $SRC_DIR ~/Source   # link to our workspace

### install and configure jhbuild ##############################################

cd $WRK_DIR
bash <(curl -s $URL_GTK_OSX_BUILD_SETUP)   # run scrip to setup jhbuild

# remove previous configuration
if [ -f $HOME/.jhbuildrc-custom ]; then
  LINE_NO=$(grep -n "# And more..." ~/.jhbuildrc-custom | awk -F ":" '{ print $1 }')
  head -n +$LINE_NO ~/.jhbuildrc-custom >~/.jhbuildrc-custom.stripped
  mv ~/.jhbuildrc-custom.stripped ~/.jhbuildrc-custom
  unset LINE_NO
fi

# configure jhbuild
echo "checkoutroot = '$SRC_DIR/checkout'" >> ~/.jhbuildrc-custom
echo "prefix = '$OPT_DIR'" >> ~/.jhbuildrc-custom
echo "_exec_prefix = '$SRC_DIR/bootstrap'" >> ~/.jhbuildrc-custom
echo "tarballdir = '$SRC_DIR/download'" >> ~/.jhbuildrc-custom
echo "quiet_mode = True" >> ~/.jhbuildrc-custom    # suppress all build output
echo "progress_bar = True" >> ~/.jhbuildrc-custom

### bootstrap jhbuild environemnt ##############################################

jhbuild bootstrap
