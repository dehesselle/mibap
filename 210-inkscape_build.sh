#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: 2021 René de Hesselle <dehesselle@web.de>
#
# SPDX-License-Identifier: GPL-2.0-or-later

### description ################################################################

# Build and install Inkscape. For non-CI builds, this will build Inkscape
# master branch. Installation prefix is VER_DIR.

### shellcheck #################################################################

# Nothing here.

### dependencies ###############################################################

# shellcheck disable=SC1090 # can't point to a single source here
for script in "$(dirname "${BASH_SOURCE[0]}")"/0??-*.sh; do
  source "$script";
done

### variables ##################################################################

# Nothing here.

### functions ##################################################################

# Nothing here.

### main #######################################################################

error_trace_enable

#-------------------------------------------------------- (re-) configure ccache

# This is required when using the precompiled toolset as ccache will not have
# been setup before (it happens in 110-sysprep.sh).

ccache_configure

#------------------------------------------------------- (re-) configure JHBuild

# This allows compiling Inkscape with a different setup than what the toolset
# was built with, most importantly a different SDK.

jhbuild_configure

#---------------------------------------------------------------- build Inkscape

if ! $CI_GITLAB; then     # not running GitLab CI

  if [ -d "$INK_DIR"/.git ]; then   # Already cloned?
    # Special treatment 1/2 for local builds: Leave it up to the
    # user if they need a fresh clone. This way we enable making changes
    # to the code and running the build again.
    echo_w "using existing repository in $INK_DIR"
    echo_w "Do 'rm -rf $INK_DIR' if you want a fresh clone."
    sleep 5
  else
    git clone \
      --branch "$INK_BRANCH" \
      --depth 10 \
      --recurse-submodules \
      --single-branch \
      "$INK_URL" "$INK_DIR"
  fi

  if ! $CI && [ -d "$INK_BLD_DIR" ]; then   # Running locally and build exists?
    # Special treatment 2/2 for local builds: remove the build directory
    # to ensure clean builds.
    rm -rf "$INK_BLD_DIR"
  fi
fi

mkdir -p "$INK_BLD_DIR"
cd "$INK_BLD_DIR" || exit 1

cmake \
  -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
  -DCMAKE_C_COMPILER_LAUNCHER=ccache \
  -DCMAKE_PREFIX_PATH="$VER_DIR" \
  -DCMAKE_INSTALL_PREFIX="$VER_DIR" \
  -GNinja \
  "$INK_DIR"

ninja
ninja install
ninja tests

#--------------------------------------------- make library link paths canonical

# Most libraries are linked to with their fully qualified paths. Some of them
# have been linked to using '@rpath', which we are not setting, therefore
# breaking the binary. Since we want Inkscape to work in unpackaged form as
# well, we adjust all offending paths to use qualified paths.
# (They will be re-adjusted later to use relative location inside the
# application bundle.)
#
# example 'ldd /Users/Shared/work/0.47/lib/inkscape/libinkscape_base.dylib':
#
#   /Users/Shared/work/0.47/lib/inkscape/libinkscape_base.dylib:
#     @rpath/libinkscape_base.dylib (compatibility version 0.0.0, ...     <- fix
#     @rpath/libboost_filesystem.dylib (compatibility version 0.0....     <- fix
#     @rpath/lib2geom.1.1.0.dylib (compatibility version 1.1.0, cu...     <- fix
#     /Users/Shared/work/0.47/lib/libharfbuzz.0.dylib (compatibili...     <- ok
#     /Users/Shared/work/0.47/lib/libpangocairo-1.0.0.dylib (compa...     <- ok
#     /Users/Shared/work/0.47/lib/libcairo.2.dylib (compatibility ...     <- ok
#     ...

for binary in $BIN_DIR/inkscape \
              $LIB_DIR/inkscape/libinkscape_base.dylib; do
  for lib in $(otool -L "$binary" |
               grep "@rpath/" |
               awk '{ print $1 }'); do
    # This here is the reason we require GNU's 'find', as the macOS one doesn't
    # pick up the files from the bottom layer of our union mount.
    lib_canonical=$(find "$LIB_DIR" -maxdepth 2 -name "$(basename "$lib")")
    lib_change_path "$lib_canonical" "$binary"
  done
done
