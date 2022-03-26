#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: 2022 René de Hesselle <dehesselle@web.de>
#
# SPDX-License-Identifier: GPL-2.0-or-later

### description ################################################################

# Bootstrap jhb. We want to use our own versioning and naming (so mutiple
# versions can coexist independent from each other on one machine), therefore we
# cannot use the pre-built bootstrap archive.

### shellcheck #################################################################

# Nothing here.

### dependencies ###############################################################

# Nothing here.

### variables ##################################################################

SELF_DIR=$(dirname "${BASH_SOURCE[0]}")

### functions ##################################################################

# Nothing here.

### main #######################################################################

#-------------------------------------------------- install custom configuration

cp "$SELF_DIR"/jhb-custom.conf.sh "$SELF_DIR"/jhb/etc

#----------------------------------------------------------------- run bootstrap

"$SELF_DIR"/jhb/usr/bin/bootstrap
