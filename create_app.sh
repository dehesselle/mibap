#!/usr/bin/env bash

#
# This script creates the application bundle.
# The main tasks are:
# - create the application bundle directory structure
# - copy all the files
# - rewrite linked (absolute) paths to be relative to app bundle (rpath) 
#

### VARIABLES ##################################################################

WORK_DIR=/Volumes/WORK
BREW_DIR=$WORK_DIR/homebrew
APP_DIR=$WORK_DIR/Inkscape.app
APP_RES_DIR=$APP_DIR/Contents/Resources
APP_LIB_DIR=$APP_RES_DIR/lib
INKSCAPE_BUILD=/Volumes/WORK/inkscape

### FUNCTIONS ##################################################################

# This functions copies all dynamically linked in libraries from 'file' (first
# argument) to the app bundle structure. It walks recursively through the
# whole dependency tree. In order to not recurse endlessly (libraries depending
# on each other), this function needs a memory of what it already processed.
# That is a simple textfile 'remember' (second argument) that needs to be
# empty on first run.
function copy_rewrite_libs
{
  local file=$1
  local remember=$2

  local line

  if [ $(grep "$file" $remember | wc -l) -eq 0 ]; then
    echo $file >> $remember   # remember files we've already processed
                              # to avoid endless recursion

    cp $file $APP_LIB_DIR
    chmod 644 $APP_LIB_DIR/*    # TODO not whole directory, plz!

    otool -L $file | while IFS="" read -r line; do
      if [[ $line =~ [^/]+(/Volumes/WORK/homebrew/[^\  ]+).* ]]; then   # FIXME hard-coded path!
        local lib=${BASH_REMATCH[1]}   # extract fully qualified filename

        if [ "$file" = "$lib" ]; then   # first line from otool is library ID
          install_name_tool -id Inkscape.app/Contents/Resources/lib/$(basename $lib) $APP_LIB_DIR/$(basename $file)
        else                            # all other lines are dependencies
          echo "$lib"   # to show on screen that something is happening
          copy_rewrite_libs $lib $remember
          
          install_name_tool -change $lib @executable_path/../Resources/lib/$(basename $lib) $APP_LIB_DIR/$(basename $file)
          #break    # for debugging: this breaks recursion
        fi
      fi
    done
  fi
}

### MAIN #######################################################################

mkdir -p $APP_DIR/Contents/MacOS
mkdir -p $APP_LIB_DIR

# This catches a lot of libraries (i.e. everything from homebrew), but not all.
# Also, the Inkscape binary is treated as library, gets (mis-) placed
# in APP_LIB_DIR and its execute flags removed.
> $WORK_DIR/remember.txt
copy_rewrite_libs $INKSCAPE_BUILD/bin/inkscape $WORK_DIR/remember.txt
# Move the misplaced Inkscape binary.
mv $APP_LIB_DIR/inkscape $APP_DIR/Contents/MacOS
# Make executable (again).
chmod 755 $APP_DIR/Contents/MacOS/inkscape

# The Inkscape binary is small, its own stuff is in libinkscape_base.dylib.
# Since that is not from homebrew, it wasn't caught during the first run.
# Running again explicitly for that library. 
copy_rewrite_libs $INKSCAPE_BUILD/lib/inkscape/libinkscape_base.dylib $WORK_DIR/remember.txt
# Manually set the ID of said library.
install_name_tool -id Inkscape.app/Contents/Resources/lib/libinkscape_base.dylib $APP_LIB_DIR/libinkscape_base.dylib
# Manually rewrite the path in Inkscape binary for said library.
install_name_tool -change @rpath/libinkscape_base.dylib @executable_path/../Resources/lib/libinkscape_base.dylib $APP_DIR/Contents/MacOS/inkscape

# There is also a binary named inkview.
copy_rewrite_libs $INKSCAPE_BUILD/bin/inkview $WORK_DIR/remember.txt
# Move the misplaced inkview binary.
mv $APP_LIB_DIR/inkview $APP_DIR/Contents/MacOS
# Make executable (again).
chmod 755 $APP_DIR/Contents/MacOS/inkview
# Manually rewrite the path in Inkscape binary for said library.
install_name_tool -change @rpath/libinkscape_base.dylib @executable_path/../Resources/lib/libinkscape_base.dylib $APP_DIR/Contents/MacOS/inkview

# Copy shared resources.
cp -R $INKSCAPE_BUILD/share $APP_RES_DIR

