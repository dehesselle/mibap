#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later
#
# This file is part of the build pipeline for Inkscape on macOS.
#
# ### 120-jhbuild_install.sh ###
# Install and configure JHBuild.

### settings and functions #####################################################

for script in $(dirname ${BASH_SOURCE[0]})/0??-*.sh; do source $script; done

include_file error_.sh
error_trace_enable

### install Python certifi package #############################################

# Without this, JHBuild won't be able to access https links later because
# Apple's Python won't be able to validate certificates.

pip3 install --ignore-installed --prefix $VER_DIR $PYTHON_CERTIFI

### install JHBuild ############################################################

install_source $JHBUILD_URL
JHBUILD_DIR=$(pwd)

# Create 'jhbuild' executable. This code has been adapted from
# https://gitlab.gnome.org/GNOME/gtk-osx/-/blob/master/gtk-osx-setup.sh
#
# This file will use '/usr/bin/python3' instead of the environment lookup
# '/usr/bin/env python3' because we want to stick with a version for
# JHBuild regardless of what Python we install later (which would
# replace that because of PATH within JHBuild environment).
cat <<EOF > "$BIN_DIR/jhbuild"
#!/usr/bin/python3
# -*- coding: utf-8 -*-

import sys
import os
import builtins

sys.path.insert(0, '$JHBUILD_DIR')
pkgdatadir = None
datadir = None
import jhbuild
srcdir = os.path.abspath(os.path.join(os.path.dirname(jhbuild.__file__), '..'))

builtins.__dict__['PKGDATADIR'] = pkgdatadir
builtins.__dict__['DATADIR'] = datadir
builtins.__dict__['SRCDIR'] = srcdir

import jhbuild.main
jhbuild.main.main(sys.argv[1:])
EOF

chmod 755 $BIN_DIR/jhbuild

### configure JHBuild ##########################################################

configure_jhbuild
