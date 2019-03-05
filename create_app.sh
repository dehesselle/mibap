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
APP_LIB_DIR=$APP_RES_DIR/lib
INKSCAPE_BUILD=/Volumes/WORK/inkscape

declare -i RECURSION=0

# warning: this function has recursion!
function get_libs
{
  local file=$1
  local remember=$2

  local line

  if [ $(grep "$file" $remember | wc -l) -eq 0 ]; then
    echo $file >> $remember   # remember files we've already processed
                              # to avoid endless recursion


    if [ $RECURSION -eq 0 ]; then   # first run is inkscape binary
      :
      cp $file $APP_DIR/Contents/MacOS
    else
      :
      cp $file $APP_LIB_DIR
      chmod 644 $APP_LIB_DIR/*    # TODO on file basis, plz!
      #install_name_tool -change $lib @executable_path/../Resources/lib/$(basename $lib) $APP_LIB_DIR/$(basename $file)
    fi

    otool -L $file | while IFS="" read -r line; do
      if [[ $line =~ [^/]+(/Volumes/WORK/homebrew/[^\  ]+).* ]]; then
        local lib=${BASH_REMATCH[1]}   # extract fully qualified filename

        if [ "$file" != "$lib" ]; then   # skip "self" in otool output
          echo "lib>$lib<"
          ((RECURSION++))
          get_libs $lib $remember
          ((RECURSION--))
          
          if [ $RECURSION -eq 0 ]; then   # first run is inkscape binary
            :
          else
            :
            install_name_tool -change $lib @executable_path/../Resources/lib/$(basename $lib) $APP_LIB_DIR/$(basename $file)
          fi
          
        
          # TODO rewrite path to rpath >>>here<<<<
          #break    # for debugging: this breaks recursion
        else
          echo "i got here"
          echo "install_name_tool -id Inkscape.app/Contents/Resources/lib/$(basename $lib) $APP_LIB_DIR/$(basename $file)"
          install_name_tool -id Inkscape.app/Contents/Resources/lib/$(basename $lib) $APP_LIB_DIR/$(basename $file)
          #exit 0
        
        fi
      fi
    done
  fi
}

mkdir -p $APP_DIR/Contents/MacOS
mkdir -p $APP_LIB_DIR

> $WORK_DIR/remember.txt
get_libs $INKSCAPE_BUILD/bin/inkscape $WORK_DIR/remember.txt


exit 0 ####################### exit for now


cp -R $INKSCAPE_BUILD/lib $APP_RES_DIR
cp -R $INKSCPAE_BUILD/share $APP_RES_DIR



