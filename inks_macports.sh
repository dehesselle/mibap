#!/usr/bin/env bash

################################################################################
#
# DO NOT RUN THIS SCRIPT. I'm not kidding, I mean that. This script
# contains FIXME to workaround temporary problems like broken portfile etc.
# and is not intended as "fire and forget" solution. (At least not in its
# current state.)
#
# For now, use it as a recipe for copy-pasting the commands as you see fit.
# This way you can check if the workarounds are still necessary.
#
################################################################################
#
# This script is meant to demonstrate the necessary steps to install
# Inkscape and XOrg on Mojave. A clean macOS 10.14.3 installation
# with nothing but Xcode installed has been used to create this.
#
################################################################################

# for non-production usage: use ramdisk
#diskutil unmountDisk WORK
#diskutil erasevolume HFS+ "WORK" $(hdiutil attach -nomount ram://$(expr 10 \* 1024 \* 2048))
#WRK_DIR=/Volumes/WORK                                                 # ^^--- unit is GiB
#MP_DIR=$WRK_DIR/mp

# settings
export MAKEFLAGS="-j8"                # <--- set number of cores here
[ -z $WRK_DIR ] && WRK_DIR=/tmp
[ -z $MP_DIR  ] && MP_DIR=/opt/mp     # <--- set MacPorts install location here
MP_USER=$(whoami)
MP_GROUP=$(id -ng $MP_USER)

# install MacPorts to MP_DIR
cd $WRK_DIR
curl -L https://distfiles.macports.org/MacPorts/MacPorts-2.5.4.tar.gz | tar xz
cd MacPorts-2.5.4
./configure --prefix=$MP_DIR --with-install-user=$MP_USER --with-install-group=$MP_GROUP --with-no-root-privileges --with-macports-user=$MP_USER --without-startupitems --with-applications-dir=$MP_DIR/Applications
make; make install
PORT=$MP_DIR/bin/port
$PORT selfupdate

# FIXME: workaround to fix a broken portfile
# (as of: 09.03.2019 01:56 CET)
sed -i 's/chneukirchen/leahneukirchen/g' $MP_DIR/var/macports/sources/rsync.macports.org/macports/release/tarballs/ports/graphics/netpbm/Portfile
$PORT install netpbm checksum.skip=yes

# install xorg
$PORT install xorg

# FIXME: installation fails with the instructions to force activate mkfontdir
# (as of: 09.03.2019 02:07 CET)
$PORT -f activate mkfontdir

# ...and continue to install xorg
$PORT install xorg

# FIXME: Installation fails because xinit needs root privileges to install
# despite having macports configured without. This is actually documented
# behavior but I don't have the link handy.
# (as of: 09.03.2019 02:35 CET)
sudo $PORT install xinit

# ...and continue to install xorg
$PORT install xorg

# install inkscape
$PORT install inkscape +x11

# FIXME: installationfails with instructions to force deactivate autoconf-archive
# (as of: 09.03.2019 ... CET, I was asleep)
$PORT -f deactivate autoconf-archive

# ...and continue to install inkscpae
$PORT isntall inkscape +x11

# fails compiling libgcc8
# (as of: 09.03.2019 12:01 CET)

