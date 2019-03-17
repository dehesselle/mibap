#!/usr/bin/env bash
# 040-jhbuild-python2.sh
# https://github.com/dehesselle/mibap
#
# Install working Python 2 w/SSL to avoid jhbuild shooting itself in the foot.

source 010-vars.sh
source 020-funcs.sh

### install OpenSSL ############################################################

# OpenSSL is required for Python to build the SSL module. Without the SSL
# module jhbuild would no longer function because all downloads are https.

get_source $URL_OPENSSL
jhbuild run ./config --prefix=$OPT_DIR
make_makeinstall
ln -sf /etc/ssl/cert.pem $OPT_DIR/ssl   # required for https certificate validation

### install Python 2 ###########################################################

# Some packages complain about non-exiting development headers when you rely
# solely on the OS-provided Python installation.

jhbuild build python

cd $SRC_DIR
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
jhbuild run python get-pip.py
jhbuild run pip install six   # required for a package in meta-gtk-osx-bootstrap
