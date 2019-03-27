# 020-funcs.sh
# https://github.com/dehesselle/mibap
#
# This file contains all the global functions and is meant to be sourced by 
# other files.

[ -z $FUNCS_INCLUDED ] && FUNCS_INCLUDED=true || return   # include guard

source 010-vars.sh

### get repository version string ##############################################

function get_repo_version
{
  local repo=$1
  #echo $(git -C $repo describe --tags --dirty)
  echo $(git -C $repo log --pretty=format:'%h' -n 1)
}

### get compression flag by filename extension #################################

function get_comp_flag
{
  local file=$1

  local extension=${file##*.}

  case $extension in
    gz) echo "z"  ;;
    bz2) echo "j" ;;
    xz) echo "J"  ;;
    *) echo "ERROR unknown extension $extension"
  esac
}

### download and extract source tarball ########################################

function get_source
{
  local url=$1
  local log=$TMP_DIR/$FUNCNAME.log

  cd $SRC_DIR

  # This downloads a file and pipes it directly into tar (file is not saved
  # to disk) to extract it. Output is saved temporarily to determine
  # the directory the files have been extracted to.
  curl -L $url | tar xv$(get_comp_flag $url) 2>$log
  cd $(head -1 $log | awk '{ print $2 }')
  rm $log
}

### make, make install in jhbuild environment ##################################

function make_makeinstall
{
  jhbuild run make
  jhbuild run make install
}

### configure, make, make install in jhbuild environment #######################

function configure_make_makeinstall
{
  local flags="$*"

  jhbuild run ./configure --prefix=$OPT_DIR $flags
  make_makeinstall
}

### cmake, make, make install in jhbuild environment ###########################

function cmake_make_makeinstall
{
  local flags="$*"

  mkdir builddir
  cd builddir
  jhbuild run cmake -DCMAKE_INSTALL_PREFIX=$OPT_DIR $flags ..
  make_makeinstall
}

