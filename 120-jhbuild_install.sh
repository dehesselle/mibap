#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later
#
# This file is part of the build pipeline for Inkscape on macOS.
#
# ### 120-jhbuild_install.sh ###
# Install and configure JHBuild.

### settings and functions #####################################################

# shellcheck disable=SC1090 # can't point to a single source here
for script in "$(dirname "${BASH_SOURCE[0]}")"/0??-*.sh; do source "$script"; done

include_file error_.sh
error_trace_enable

#-- install Python certifi package ---------------------------------------------

# Without this, JHBuild won't be able to access https links later because
# Apple's Python won't be able to validate certificates.

pip3 install --ignore-installed --prefix "$VER_DIR" "$PYTHON_CERTIFI"

#-- install JHBuild ------------------------------------------------------------

jhbuild_install

#-- configure JHBuild ----------------------------------------------------------

jhbuild_configure
