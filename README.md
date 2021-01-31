# **m**acOS **I**nkscape **b**uild **a**nd **p**ackage

![build](https://github.com/dehesselle/mibap/workflows/mibap/badge.svg)

This repository is the development platform for building and packaging [Inkscape](https://inkscape.org) 1.x on macOS. That means updates happen here more frequently and in smaller steps than what is pushed (in accumulated/squashed form) to Inkscape's sources ([packaging/macos](https://gitlab.com/inkscape/inkscape/-/tree/master/packaging/macos)).

The build system being used is [JHBuild](https://gitlab.gnome.org/GNOME/jhbuild) in conjunction with our own custom moduleset based off [gtk-osx](https://gitlab.gnome.org/GNOME/gtk-osx). If you have never heard about these two, take a look at [GTK's documentation](https://www.gtk.org/docs/installations/macos/); it is important to understand that this is neither Homebrew nor MacPorts. But don't worry, everything has been automated to the point that you only have to run shell scripts.

## Build instructions

Building Inkscape is a two-step process:

1. Setup a build environment with all the dependencies ("toolset"). There are two options:

   a. Build everything from scratch. This encompasses _a lot_ of libraries and helper tools, therefore this is time consuming and can be error-prone if you don't stick to the requirements/recommendations.

   __or__

   b. Use a precompiled version of the toolset. Comparatively quick and painless, this will download and mount a disk image.

1. Build Inkscape.  
   You can get from source code to disk image in under 5 minutes.

### Requirements

- A __clean environment__ is key.
  - Make sure there are no remnants from other build environments (e.g. Homebrew, MacPorts, Fink) on your system.
    - Rule of thumb: clear out `/usr/local`.
  - Use a dedicated user account to avoid any interference with the environment (e.g. no custom settings in `.profile`, `.bashrc`, etc.).

- There are __version recommendations__.
  - macOS Catalina 10.15.7
  - Xcode 12.3
  - OS X El Capitan 10.11 SDK (from Xcode 7.3.1)

- An __internet connection__ for all the downloads.

### step 1a: build the toolset

1. Clone this repository and `cd` into it.

   ```bash
   git clone --recurse-submodules https://github.com/dehesselle/mibap
   cd mibap
   ```

1. _(optional)_ Set a build directory (default: `/Users/Shared/work`).

   ```bash
   # Don't blindly copy/paste this. No spaces allowed.
   echo "WRK_DIR=$HOME/my_build_dir" > 015-customdir.sh
   ```

1. _(optional)_ Set the SDK to be used (default: `xcodebuild -version -sdk macosx Path`).

   ```bash
   # Don't blindly copy/paste this. No spaces allowed.
   echo "SDKROOT=$HOME/MacOSX10.11.sdk" > 015-sdkroot.sh
   ```

1. Build the toolset.

   ```bash
   ./build_toolset.sh
   ```

   This will

   - run all the `1nn`-prefixed scripts consecutively
   - populate `$WRK_DIR/$TOOLSET_VER`

Time for ☕, this will take a while!

### step 1b: install a precompiled toolset

1. Acknowledge that the precompiled toolset requires `WRK_DIR=/Users/Shared/work` as build directory. (It's the default, no need to configure this.)

1. Clone this repository and `cd` into it.

   ```bash
   git clone --recurse-submodules https://github.com/dehesselle/mibap
   cd mibap
   ```

1. Install the toolset.

   ```bash
   ./install_toolset.sh
   ```

   This will

   - download a disk image (about 1.6 GiB) to `/Users/Shared/work/repo`
   - mount the (read-only) disk image to `/Users/Shared/work/$TOOLSET_VER`
   - union mount a ramdisk (3 GiB) to `/Users/Shared/work/$TOOLSET_VER`

   The mounted volumes won't show up in Finder but you can see them using `diskutil list`.

   _Once you're done compiling Inkscape, use `uninstall_toolset.sh` to eject them. This does not delete the contents of `/Users/Shared/work/repo`._

### step 2: build Inkscape

1. Build Inkscape.

   ```bash
   ./build_inkscape.sh
   ```

   This will

   - run all the `2nn`-prefixed scripts consecutively
   - produce `$WRK_DIR/$TOOLSET_VER/artifacts/Inkscape.dmg`

## GitHub CI

Under investigation - GitHub hosted runners do not provide a clean environment as per the requirements above.
## known issues

Besides what you may find in the issue tracker:

- If you're logged in to the desktop when building the toolset, you may get multiple popups asking to install Java. They're triggered by at least `gettext` and `cmake` checking for the presence of Java during their configuration stages and can be safely ignored.

## Status

This project is still a work in progress (hence 0.x version).

## Contact

If you want to reach out, join `#team_devel_mac` on [Inkscape's RocketChat](https://chat.inkscape.org/).

## License

[GPL-2.0-or-later](LICENSE)
