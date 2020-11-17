# mibap - macOS Inkscape build and package

This repository is the development platform for building and packaging [Inkscape](https://inkscape.org) 1.x on macOS.

## Usage

### Requirements

_The following is bound to change as development progresses and I won't deny that there's usually more than one way to do something, but I can only support what I use myself. So feel free to experiment and deviate, but know that __it is dangerous to go alone! Take this 🗡️.___

- A __clean environment__ is key.
  - Make sure there are no remnants from other build environments (e.g. MacPorts, Fink, Homebrew) on your system.
    - Rule of thumb: clear out `/usr/local`.
  - Use a dedicated user account to avoid any interference with the environment (e.g. no custom settings in `.profile`, `.bashrc`, etc.).

- There are __version recommendations__.
  - macOS Catalina 10.15.7
  - Xcode 12.2
  - OS X El Capitan 10.11 SDK from Xcode 7.3.1 (expected in `/opt/sdks/MacOSX10.11.sdk`, see `SDKROOT_DIR` in `020-vars.sh`)

- A somewhat decent __internet connection__ for all the downloads.

### Building the toolset

ℹ️ _If you only want to build Inkscape and not the complete toolset, skip ahead to the next section!_

1. Clone this repository and `cd` into it.

   ```bash
   git clone --recurse-submodules https://github.com/dehesselle/mibap
   cd mibap
   ```

2. Specify a folder where all the action is going to take place. (Please avoid spaces in paths!)

   ```bash
   echo "WRK_DIR=$HOME/my_build_dir" > 015-customdir.sh  # set work directory
   ```

3. Build the toolset.

   ```bash
   ./build_toolset.sh
   ```

4. ☕ (Time to get a beverage - this will take a while!)

### Installing a pre-compiled toolset

ℹ️ _If you just built the toolset yourself, skip ahead to the next section!_

ℹ️ _Using `/Users/Shared/work` as `WRK_DIR` is mandatory! (This is the default, see `020-vars.sh`.)_

1. Clone this repository and `cd` into it.

   ```bash
   git clone --recurse-submodules https://github.com/dehesselle/mibap
   cd mibap
   ```

2. Install the toolset.

   ```bash
   ./install_toolset.sh
   ```

   This will

   - download a disk image (about 1.6 GiB) to `/Users/Shared/work/repo`
   - mount the (read only) disk image to `/Users/Shared/work/$TOOLSET_VERSION`
   - union-mount a ramdisk (3 GiB) to `/Users/Shared/work/$TOOLSET_VERSION`

   The mounted volumes won't show up in the Finder but you can see them using `diskutil`. Use `uninstall_toolset.sh` to eject them (`repo` will not be deleted though).

### Building Inkscape

1. Build Inkscape.

   ```bash
   ./build_inkscape.sh
   ```

   Ultimately this will produce `/Users/Shared/work/$TOOLSET_VERSION/artifacts/Inkscape.dmg`.

## known issues

Besides what you may find in the issue tracker:

- If you're logged in to the desktop when building the toolset, you may get multiple popups asking to install Java. They're triggered by at least `gettext` and `cmake` checking for the presence of Java during their configuration stages and can be safely ignored.

- Bootstrapping JHBuild may print a warning on the console:

  > Warning: the environment variable LANG is not set!

## Status

This project is still a work-in-progress (hence 0.x version) with regular merges to Inkscape (see `packaging/macos` in [Inkscape's repository on GitLab](https://gitlab.com/inkscape/inkscape)).

## Contact

If you want to reach out, join `#team_devel_mac` on [Inkscape's RocketChat](https://chat.inkscape.org/).

## License

[GPL](LICENSE)
