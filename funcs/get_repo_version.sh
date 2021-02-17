# SPDX-License-Identifier: GPL-2.0-or-later
#
# This file is part of the build pipeline for Inkscape on macOS.

# shellcheck shell=bash # no shebang as this file is intended to be sourced

### get repository version string ##############################################

function get_repo_version
{
  local repo=$1
  # do it the same way as in CMakeScripts/inkscape-version.cmake
  git -C "$repo" rev-parse --short HEAD
}