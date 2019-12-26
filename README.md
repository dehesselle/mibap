# mibap - macOS Inkscape build and package

This repository is the development platform for building and packaging [Inkscape](https://inkscape.org) 1.x on macOS.

## Usage

### Recommendations

_These tend to change as development progresses (as they already have a few times) and I won't deny that there's usually more than one way to do something, but I can only support what I use myself. So feel free to experiment and deviate, but know that __it is dangerous to go alone! Take this 🗡️.___

- __A clean environment is key.__
  - Make sure there are no remnants from other build environments (e.g. MacPorts, Fink, Homebrew) on your system.
    - Rule of thumb: clear out `/usr/local`.
  - Use macOS Mojave 10.14.6 with Xcode 10.3.
  - Copy OS X Mavericks 10.9 SDK from Xcode 6.3 to `/Library/Developer/CommandLineTools/SDKs/MacOSX10.9.sdk`.

- __Use a dedicated user account__ to avoid any interference with the environment (e.g. no custom settings in `.profile`, `.bashrc`, etc.).

- A somewhat decent __internet connection__ for all the downloads.

### Building the toolset

ℹ️ _If you only want to build Inkscape and not the complete toolset, skip ahead to the next section!_

1. Clone this repository and `cd` into it.

   ```bash
   git clone https://github.com/dehesselle/mibap
   cd mibap
   ```

2. Specify a folder where all the action is going to take place. (Please avoid spaces in paths!)

   ```bash
   echo "TOOLSET_ROOT_DIR=$HOME/my_build_dir" > 015-customdir.sh
   ```

3. Build the toolset.

   ```bash
   ./build_toolset.sh
   ```

4. ☕ (Time to get a beverage - this will take a while!)

### Installing a pre-compiled toolset

ℹ️ _If you built the toolset yourself, skip ahead to the next section!_

ℹ️ _Using `/Users/Shared/work` as `TOOLSET_ROOT_DIR` is mandatory! (This is the default.)_

1. Clone this repository and `cd` into it.

   ```bash
   git clone https://github.com/dehesselle/mibap
   cd mibap
   ```

2. Install the toolset.

   ```bash
   ./install_toolset.sh
   ```

   You should know what that actually does:

   - download a disk image (about 1.6 GiB) to `/Users/Shared/work/repo`
   - mount the disk image to `/Users/Shared/work/$TOOLSET_VERSION`
   - union-mount a ramdisk (2 GiB) to `/Users/Shared/work/$TOOLSET_VERSION`

   The mounted volumes won't show up in the Finder but you can see them using `diskutil`. Use `uninstall_toolset.sh` to eject them (this won't delete `repo` though).

### Building Inkscape

1. Build Inkscape.

   ```bash
   ./build_inkscape.sh
   ```

   Ultimately this will produce `/Users/Shared/work/$TOOLSET_VERSION/artifacts/Inkscape.dmg`.

## known issues

Besides what you may find in the issue tracker:

- If you're logged in to the desktop when building the toolset, you may get multiple popups asking to install Java. They're triggered by at least `gettext` and `cmake` checking for the presence of Java during their configuration stages and can be safely ignored.

## Status

This project is still a work-in-progress (hence 0.x version) with regular merges to Inkscape (see `packaging/macos` in [Inkscape's repository on GitLab](https://gitlab.com/inkscape/inkscape)).

## Contact

If you want to reach out, join `#team_devel_mac` on [Inkscape's RocketChat](https://chat.inkscape.org/).

## License

[GPL](LICENSE)
