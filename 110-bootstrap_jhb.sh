#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: 2022 René de Hesselle <dehesselle@web.de>
#
# SPDX-License-Identifier: GPL-2.0-or-later

### description ################################################################

# Bootstrap jhb with our slightly customized configuration. We use our own
# versioning and naming scheme, making this incompatible with the pre-built
# bootstrapped jhb archive (everything will be built from scratch here).

### shellcheck #################################################################

# Nothing here.

### dependencies ###############################################################

# Nothing here.

### variables ##################################################################

SELF_DIR=$(dirname "${BASH_SOURCE[0]}")

### functions ##################################################################

# Nothing here.

### main #######################################################################

"$SELF_DIR"/jhb/usr/bin/bootstrap "$SELF_DIR"/src/jhb-custom.conf.sh
