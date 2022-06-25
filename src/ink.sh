# SPDX-FileCopyrightText: 2021 René de Hesselle <dehesselle@web.de>
#
# SPDX-License-Identifier: GPL-2.0-or-later

### description ################################################################

# This file contains everything related to Inkscape.

### shellcheck #################################################################

# shellcheck shell=bash # no shebang as this file is intended to be sourced
# shellcheck disable=SC2034 # multipe vars only used outside this script

### dependencies ###############################################################

# Nothing here.

### variables ##################################################################

#----------------------------------------------- source directory and git branch

# There are 3 possible scenarios:
#
#   1. We're running inside GitLab CI:
#      The repository has already been cloned, set INK_DIR accordingly.
#
#   2. We're not running inside GitLab CI and INK_DIR has been set:
#      Use INK_DIR provided as-is, we expect the source to be there.
#
#   3. We're not running inside GitLab CI and INK_DIR has not been set:
#      Set INK_DIR to our default location, we'll clone the repo there.

if $CI_GITLAB; then   # running GitLab CI
  INK_DIR=$CI_PROJECT_DIR
else                  # not running GitLab CI
  # Use default directory if not provided.
  if [ -z "$INK_DIR" ]; then
    INK_DIR=$SRC_DIR/inkscape
  fi

  # Allow using a custom Inkscape repository and branch.
  if [ -z "$INK_URL" ]; then
    INK_URL=https://gitlab.com/inkscape/inkscape
  fi

  # Allow using a custom branch.
  if [ -z "$INK_BRANCH" ]; then
    INK_BRANCH=master
  fi
fi

INK_BLD_DIR=$BLD_DIR/$(basename "$INK_DIR")  # we build out-of-tree

#------------------------------------ Python runtime to be bundled with Inkscape

# Inkscape will be bundled with its own (customized) Python 3 runtime to make
# the core extensions work out-of-the-box.

INK_PYTHON_VER_MAJOR=3
INK_PYTHON_VER_MINOR=10
INK_PYTHON_VER=$INK_PYTHON_VER_MAJOR.$INK_PYTHON_VER_MINOR
INK_PYTHON_URL="https://gitlab.com/api/v4/projects/26780227/packages/generic/\
python_macos/12/python_${INK_PYTHON_VER/./}_$(uname -m)_inkscape.tar.xz"
INK_PYTHON_ICON_URL="https://gitlab.com/inkscape/vectors/content/-/raw/\
5f4f4cdf/branding/projects/extensions_c1.svg"

#----------------------------------- Python packages to be bundled with Inkscape

# https://pypi.org/project/appdirs/
INK_PYTHON_PKG_APPDIRS=appdirs==1.4.4

# https://pypi.org/project/beautifulsoup4/
# https://pypi.org/project/soupsieve/
INK_PYTHON_PKG_BEAUTIFULSOUP4="\
  beautifulsoup4==4.10.0\
  soupsieve==2.3.1\
"

# https://pypi.org/project/CacheControl/
# https://pypi.org/project/certifi/
# https://pypi.org/project/charset-normalizer/
# https://pypi.org/project/idna/
# https://pypi.org/project/lockfile/
# https://pypi.org/project/msgpack/
# https://pypi.org/project/requests/
# https://pypi.org/project/urllib3/
INK_PYTHON_PKG_CACHECONTROL="\
  CacheControl==0.12.10\
  certifi==2021.10.8\
  charset_normalizer==2.0.11\
  idna==3.3\
  lockfile==0.12.2\
  msgpack==1.0.3\
  requests==2.27.1\
  urllib3==1.26.8\
"

# https://pypi.org/project/cssselect/
INK_PYTHON_PKG_CSSSELECT=cssselect==1.1.0

# https://pypi.org/project/lxml/
INK_PYTHON_PKG_LXML=lxml==4.7.1

# https://pypi.org/project/numpy/
INK_PYTHON_PKG_NUMPY=https://files.pythonhosted.org/packages/\
b4/85/8097082c4794d854e40f84639c83e33e516431faaeb9cecba39eba6921d5/\
numpy-1.22.1-cp310-cp310-macosx_10_9_universal2.whl

# https://pypi.org/project/Pillow/
INK_PYTHON_PKG_PILLOW=Pillow==9.0.0

# https://pypi.org/project/pycairo/
# https://pypi.org/project/PyGObject/
INK_PYTHON_PKG_PYGOBJECT="\
  PyGObject==3.42.1\
  pycairo==1.21.0\
"

# https://pypi.org/project/pyserial/
INK_PYTHON_PKG_PYSERIAL=pyserial==3.5

# https://pypi.org/project/scour/
# https://pypi.org/project/six/
INK_PYTHON_PKG_SCOUR="\
  scour==0.38.2\
  six==1.16.0\
  packaging==21.3 \
  pyparsing==3.0.7 \
"

#------------------------------------------- application bundle directory layout

INK_APP_DIR=$ARTIFACT_DIR/Inkscape.app

INK_APP_CON_DIR=$INK_APP_DIR/Contents
INK_APP_RES_DIR=$INK_APP_CON_DIR/Resources
INK_APP_FRA_DIR=$INK_APP_CON_DIR/Frameworks
INK_APP_BIN_DIR=$INK_APP_RES_DIR/bin
INK_APP_ETC_DIR=$INK_APP_RES_DIR/etc
INK_APP_EXE_DIR=$INK_APP_CON_DIR/MacOS
INK_APP_LIB_DIR=$INK_APP_RES_DIR/lib
INK_APP_SPK_DIR=$INK_APP_LIB_DIR/python$INK_PYTHON_VER/site-packages

### functions ##################################################################

function ink_get_version
{
  local file=$INK_DIR/CMakeLists.txt
  local ver_major
  ver_major=$(grep INKSCAPE_VERSION_MAJOR "$file" | head -n 1 |
    awk '{ print $2+0 }')
  local ver_minor
  ver_minor=$(grep INKSCAPE_VERSION_MINOR "$file" | head -n 1 |
    awk '{ print $2+0 }')
  local ver_patch
  ver_patch=$(grep INKSCAPE_VERSION_PATCH "$file" | head -n 1 |
    awk '{ print $2+0 }')
  local ver_suffix
  ver_suffix=$(grep INKSCAPE_VERSION_SUFFIX "$file" | head -n 1 |
    awk '{ print $2 }')

  ver_suffix=${ver_suffix%\"*}  # remove "double quotes and all" from end
  ver_suffix=${ver_suffix#\"}   # remove "double quote" from beginning

  echo "$ver_major.$ver_minor.$ver_patch$ver_suffix"
}

function ink_get_repo_shorthash
{
  # do it the same way as in CMakeScripts/inkscape-version.cmake
  git -C "$INK_DIR" rev-parse --short HEAD
}

function ink_pipinstall
{
  local packages=$1     # name of variable that resolves to list of packages
  local options=$2      # optional

  # turn package names into filenames of our wheels
  local wheels
  for package in $(eval echo \$"$packages"); do
    if [ "${package::8}" = "https://" ]; then
      package=$(basename "$package")
    else
      package=$(eval echo "${package/==/-}"*.whl)
    fi

    # If present in TMP_DIR, use that. This is how the externally built
    # packages can be fed into this.
    if [ -f "$TMP_DIR/$package" ]; then
      wheels="$wheels $TMP_DIR/$package"
    else
      wheels="$wheels $PKG_DIR/$package"
    fi
  done

  local path_original=$PATH
  export PATH=$INK_APP_FRA_DIR/Python.framework/Versions/Current/bin:$PATH

  # shellcheck disable=SC2086 # we need word splitting here
  pip$INK_PYTHON_VER_MAJOR install \
    --prefix "$INK_APP_RES_DIR" \
    --ignore-installed \
    $options \
    $wheels

  export PATH=$path_original

  local ink_pipinstall_func
  ink_pipinstall_func=ink_pipinstall_$(echo "${packages##*_}" |
    tr "[:upper:]" "[:lower:]")

  if declare -F "$ink_pipinstall_func" > /dev/null; then
    $ink_pipinstall_func
  fi
}

function ink_pipinstall_lxml
{
  lib_change_paths \
    @loader_path/../../.. \
    "$INK_APP_LIB_DIR" \
    "$INK_APP_SPK_DIR"/lxml/etree.cpython-"${INK_PYTHON_VER/./}"-darwin.so \
    "$INK_APP_SPK_DIR"/lxml/objectify.cpython-"${INK_PYTHON_VER/./}"-darwin.so
}

function ink_pipinstall_numpy
{
  sed -i '' '1s|.*|#!/usr/bin/env python'"$INK_PYTHON_VER_MAJOR"'|' \
    "$INK_APP_BIN_DIR"/f2py
  sed -i '' '1s|.*|#!/usr/bin/env python'"$INK_PYTHON_VER_MAJOR"'|' \
    "$INK_APP_BIN_DIR"/f2py$INK_PYTHON_VER_MAJOR
  sed -i '' '1s|.*|#!/usr/bin/env python'"$INK_PYTHON_VER_MAJOR"'|' \
    "$INK_APP_BIN_DIR"/f2py$INK_PYTHON_VER

  find "$INK_APP_LIB_DIR/python$INK_PYTHON_VER/site-packages/numpy" \
    '(' -name "*.so" -o -name "*.dylib" ')' \
    -exec codesign --remove-signature {} \;

  find "$INK_APP_LIB_DIR/python$INK_PYTHON_VER/site-packages/numpy" \
    -name "*.a" -delete
}

function ink_pipinstall_pygobject
{
  lib_change_paths \
    @loader_path/../../.. \
    "$INK_APP_LIB_DIR" \
    "$INK_APP_SPK_DIR"/gi/_gi.cpython-"${INK_PYTHON_VER/./}"-darwin.so \
    "$INK_APP_SPK_DIR"/gi/_gi_cairo.cpython-"${INK_PYTHON_VER/./}"-darwin.so \
    "$INK_APP_SPK_DIR"/cairo/_cairo.cpython-"${INK_PYTHON_VER/./}"-darwin.so
}

function ink_pipinstall_pyserial
{
  find "$INK_APP_SPK_DIR"/serial -type f -name "*.pyc" -exec rm {} \;
  sed -i '' '1s|.*|#!/usr/bin/env python3|' \
    "$INK_APP_BIN_DIR"/pyserial-miniterm
  sed -i '' '1s|.*|#!/usr/bin/env python3|' "$INK_APP_BIN_DIR"/pyserial-ports
}

function ink_pipinstall_scour
{
  sed -i '' '1s|.*|#!/usr/bin/env python3|' "$INK_APP_BIN_DIR"/scour
}

function ink_download_python
{
  curl -o "$PKG_DIR"/"$(basename "${INK_PYTHON_URL%\?*}")" -L "$INK_PYTHON_URL"
  curl -o "$PKG_DIR"/"$(basename "$INK_PYTHON_ICON_URL")" \
    -L "$INK_PYTHON_ICON_URL"
}

function ink_install_python
{
  mkdir "$INK_APP_FRA_DIR"
  tar -C "$INK_APP_FRA_DIR" -xf "$PKG_DIR"/"$(basename "${INK_PYTHON_URL%\?*}")"

  # link it to INK_APP_BIN_DIR so it'll be in PATH for the app
  mkdir -p "$INK_APP_BIN_DIR"
  # shellcheck disable=SC2086 # it's an integer
  ln -sf ../../Frameworks/Python.framework/Versions/Current/bin/\
python$INK_PYTHON_VER_MAJOR "$INK_APP_BIN_DIR"

  # create '.pth' file inside Framework to include our site-packages directory
  # shellcheck disable=SC2086 # it's an integer
  echo "../../../../../../../Resources/lib/python$INK_PYTHON_VER/site-packages"\
    > "$INK_APP_FRA_DIR"/Python.framework/Versions/Current/lib/\
python$INK_PYTHON_VER/site-packages/inkscape.pth

  # use custom icon for Python.app
  svg2icns \
    "$PKG_DIR/$(basename "$INK_PYTHON_ICON_URL")" \
    "$INK_APP_FRA_DIR/Python.framework/Resources/Python.app/Contents/\
Resources/PythonInterpreter.icns" \
    8
}

function ink_build_wheels
{
  jhb run pip3 install wheel

  for package_set in ${!INK_PYTHON_PKG_*}; do
    local packages
    for package in $(eval echo \$"$package_set"); do
      if [ "${package::8}" = "https://" ]; then
        curl -L -o "$PKG_DIR/$(basename "$package")" "$package"
      else
        packages="$packages $package"
      fi
    done

    if [ -n "$packages" ]; then
      # shellcheck disable=SC2086 # we need word splitting here
      jhb run pip3 wheel --no-binary :all: $packages -w "$PKG_DIR"
      packages=""
    fi
  done
}

### main #######################################################################

# Nothing here.