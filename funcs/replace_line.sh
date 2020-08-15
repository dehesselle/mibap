# SPDX-License-Identifier: GPL-2.0-or-later
#
# This file is part of the build pipeline for Inkscape on macOS.

### replace line that matches pattern ##########################################

function replace_line
{
  local file=$1
  local pattern=$2
  local replacement=$3

  sed -i '' "s/.*${pattern}.*/$(escape_sed $replacement)/" $file
}