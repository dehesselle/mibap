#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later
#
# This file is part of the build pipeline for Inkscape on macOS.
#
# ### 160-jhbuild_other.sh ###
# Install additional components that are not direct dependencies, like tools
# required for packaging.

### settings and functions #####################################################

# shellcheck disable=SC1090 # can't point to a single source here
for script in "$(dirname "${BASH_SOURCE[0]}")"/0??-*.sh; do source "$script"; done

include_file error_.sh
error_trace_enable

#-- install disk image creator -------------------------------------------------

dmgbuild_install

#-- install gtk-mac-bundler ----------------------------------------------------

jhbuild build gtkmacbundler

#-- install svg to icns convertor ----------------------------------------------

svg2icns_install

#-- downlaod a pre-built Python.framework --------------------------------------

# This will be bundled with the application.

download_url "$PYTHON_INK_URL" "$PKG_DIR"
