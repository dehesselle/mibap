# SPDX-FileCopyrightText: 2021 René de Hesselle <dehesselle@web.de>
#
# SPDX-License-Identifier: GPL-2.0-or-later

### description ################################################################

# cairosvg is a Python package so we can convert svg to png.

### shellcheck #################################################################

# shellcheck shell=bash # no shebang as this file is intended to be sourced

### dependencies ###############################################################

# Nothing here.

### variables ##################################################################

# https://cairocffi.readthedocs.io/en/stable/
# https://github.com/Kozea/cairocffi
# https://cairosvg.org
# https://github.com/Kozea/CairoSVG
CAIROSVG_PIP="\
  cairocffi==1.2.0\
  cairosvg==2.5.2\
"

### functions ##################################################################

function cairosvg_install
{
  # shellcheck disable=SC2086 # we need word splitting here
  jhb run pip3 install $CAIROSVG_PIP
}

### main #######################################################################

# Nothing here.