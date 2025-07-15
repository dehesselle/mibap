# building and packaging Inkscape on macOS

![mibap_icon](./resources/mibap_icon.png)
![pipeline status](https://gitlab.com/inkscape/deps/macos/badges/master/pipeline.svg)
![Latest Release](https://gitlab.com/inkscape/deps/macos/-/badges/release.svg)

This repository (on [GitLab](https://gitlab.com/inkscape/deps/macos), [GitHub](https://github.com/dehesselle/mibap)) is the development platform for building and packaging [Inkscape](https://inkscape.org) 1.x on macOS. It creates a disk image containing all dependencies and provides the build scripts that are being used in Inkscape's CI.

Its working title was/is "mibap" (short for "macOS Inkscape build and package") which is still being used in a few places.

## Under the hood

The build system being used is [JHBuild](https://gitlab.gnome.org/GNOME/jhbuild) with a custom moduleset based on [gtk-osx](https://gitlab.gnome.org/GNOME/gtk-osx). If you have never heard about these two, take a look at [GTK's documentation](https://www.gtk.org/docs/installations/macos/); it is important to understand that this is neither Homebrew nor MacPorts. But don't worry, in the end it's just another orchestration tool to perform "configure; make; make install" and manage dependencies.

## Building Inkscape's dependencies

### Prerequisites

- A __clean environment__ is key. This is the most inconvenient requirement as it will likely conflict with how you are currently using your Mac, but it is vital.
  - Software and libraries - usually installed via package managers like Homebrew, MacPorts, Fink etc. - are known to cause problems depending on installation prefix. You cannot have software installed in the following locations:
    - `/usr/local`
    - `/opt/homebrew`
    - `/opt/local`
  - Uninstall Xquartz.
  - Use a dedicated user account to avoid any interference with the environment.
    - No customizations in dotfiles like `.profile`, `.bashrc` etc.

- There are __version recommendations__ based on a known working setup (used in CI), targeting the minimum supported OS versions (see [`sys.sh`](etc/jhb.conf.d/sys.sh)).
  - macOS Monterey 12.6.x
  - Xcode 14.0.1 (last version containing Monterey 12.3 SDK)
  - macOS High Sierra 10.13.4 SDK (from Xcode 9.4.1) for `x86_64` architecture
  - macOS Big Sur 11.3 SDK (from Xcode 13.0) for `arm64` architecture

- An __internet connection__ for all the downloads.

### Steps

1. Clone this repository and `cd` into it.

   ```bash
   git clone --recurse-submodules https://github.com/dehesselle/mibap
   cd mibap
   ```

1. _(optional)_ Set a build directory (default: `/Users/Shared/work`).

   ```bash
   # Optional. Avoid spaces.
   export WRK_DIR=$HOME/my_build_dir
   ```

1. _(optional)_ Use a specific SDK (default: `xcodebuild -version -sdk macosx Path`).

   ```bash
   # Optional. Avoid spaces.
   export SDKROOT=$HOME/MacOSX10.13.sdk
   ```

1. Build all dependencies.

   ```bash
   ./110-bootstrap_jhb.sh
   ./120-build_gtk4.sh
   ./130-build_inkdeps.sh
   ./140-build_packaging.sh
   ```

   This will
   - build everything in your `$WRK_DIR`
   - take some time!

## Building Inkscape

<!-- markdownlint-disable MD024 -->
### Prerequisites
<!-- markdownlint-enable MD024 -->

- The precompiled toolset requires `/Users/Shared/work` as build directory.

<!-- markdownlint-disable MD024 -->
### Steps
<!-- markdownlint-enable MD024 -->

1. Clone this repository and `cd` into it. Checkout the latest tag, do not use master. Initialize and update the submodules.

   ```bash
   git clone https://github.com/dehesselle/mibap
   cd mibap
   # checkout tag with highest version number
   git checkout $(git tag | grep "^v" | sort -V | tail -1)
   # pull in submodules
   git submodule update --init --recursive
   ```

1. Install the dependencies.

   ```bash
   jhb/usr/bin/archive install_dmg
   ```

   This will

   - download the latest [release](https://gitlab.com/inkscape/deps/macos/-/releases) (about 300 MiB) to `/Users/Shared/work/repo`
   - mount the disk image to `/Users/Shared/work/mibap-N.N`

   The mounted volume won't show up in Finder (on purpose) but you can see it using `diskutil list`.  
   A temporary file ending in `.dmg.shadow` will be created in `/Users/Shared/work` and will be automatically discarded when uninstalling.

1. Set `INK_DIR` to your clone of Inkscape's repository and start the build.

   ```bash
   # Clone Inkscape's sources if you haven't done this yet:
   # git clone --recurse-submodules https://gitlab.com/inkscape/inkscape $HOME/inkscape
   export INK_DIR=$HOME/inkscape
   ./210-inkscape_build.sh
   ./220-inkscape_package.sh
   ./230-inkscape_distrib.sh
   ```

   This will

   - build and install Inkscape to `/Users/Shared/work/mibap-<version>`
   - create `Inkscape*.dmg` in your working directory

1. Uninstall the dependencies.

   ```bash
   jhb/usr/bin/archive uninstall_dmg
   ```

## Contact

If you want to reach out, join [#team_devel](https://chat.inkscape.org/channel/team_devel) on Inkscape's RocketChat.

## Credits

The mibap icon uses a [red apple](https://openclipart.org/detail/190698/apple-with-bite) and [gears](https://openclipart.org/detail/176293/meshed-gears) from [Openclipart](https://openclipart.org), licensed under [CC0-1.0](https://spdx.org/licenses/CC0-1.0.html).

## License

[GPL-2.0-or-later](LICENSE)
