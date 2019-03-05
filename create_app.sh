#!/usr/bin/env bash

#
# This script creates the application bundle.
# The main tasks are:
# - create the application bundle directory structure
# - copy all the files
# - rewrite linked (absolute) paths to be relative to app bundle (rpath) 
#

WORK_DIR=/Volumes/WORK
BREW_DIR=$WORK_DIR/homebrew
APP_DIR=$WORK_DIR/Inkscape.app
APP_RES_DIR=$APP_DIR/Contents/Resources
INKSCAPE_BUILD=/Volumes/WORK/inkscape


# warning: this function has recursion!
function get_libs
{
  local file=$1
  local remember=$2

  local line
  local lib

  if [ $(grep "$file" $remember | wc -l) -eq 0 ]; then
    echo $file >> $remember   # remember files we've already processed
                              # to avoid endless recursion

    otool -L $file | while IFS="" read -r line; do
      if [[ $line =~ [^/]+(/Volumes/WORK/homebrew/[^\  ]+).* ]]; then
        lib=${BASH_REMATCH[1]}   # extract fully qualified filename

        if [ "$file" != "$lib" ]; then   # skip "self" in otool output
          echo "lib>$lib<"
          get_libs $lib $remember
          # TODO rewrite path to rpath >>>here<<<<
          #break    # for debugging: this breaks recursion
        fi
      fi
    done
  fi
}

> $WORK_DIR/remember.txt
get_libs $INKSCAPE_BUILD/bin/inkscape $WORK_DIR/remember.txt


exit 0 ####################### exit for now

mkdir -p $APP_DIR/Contents/MacOS
mkdir -p $APP_RES_DIR


cp -R $INKSCAPE_BUILD/lib $APP_RES_DIR
cp -R $INKSCPAE_BUILD/share $APP_RES_DIR


