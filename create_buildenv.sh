#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later
#
# This file is part of the build pipeline for Inkscape on macOS.
#
# ### create_buildenv.sh ###
# create jhbuild environment for Inkscape

for script in 1??-*.sh; do
  ./$script
done

