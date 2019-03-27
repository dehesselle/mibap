#!/usr/bin/env bash
# 040-jhbuild-python2.sh
# https://github.com/dehesselle/mibap
#
# Install working Python 2 w/SSL.

SELF_DIR=$(cd $(dirname "$0"); pwd -P)
source $SELF_DIR/010-vars.sh
source $SELF_DIR/020-funcs.sh

### install OpenSSL ############################################################

# Build OpenSSL as dedicated step because we need to link our system
# configuration and certs (/etc/ssl) to it. Otherwise https downloads
# will fail with certification validation issues.

jhbuild build openssl
mkdir -p $OPT_DIR/etc
ln -sf /etc/ssl $OPT_DIR/etc   # link system config to our OpenSSL

### install Python 2 ###########################################################

# Some packages complain about non-exiting development headers when you rely
# solely on the macOS-provided Python installation. This also enables 
# system-wide installations of packages without permission issues.

jhbuild build python

cd $SRC_DIR
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
jhbuild run python get-pip.py
jhbuild run pip install six   # required for a package in meta-gtk-osx-bootstrap
