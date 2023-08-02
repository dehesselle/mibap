# macOS Inkscape build and package (mibap)

![mibap_icon](./resources/mibap_icon.png)
![pipeline status](https://gitlab.com/inkscape/deps/macos/badges/master/pipeline.svg)
![Latest Release](https://gitlab.com/inkscape/deps/macos/-/badges/release.svg)

This repository (on [GitLab](https://gitlab.com/inkscape/deps/macos), [GitHub](https://github.com/dehesselle/mibap)) is the development platform for building and packaging [Inkscape](https://inkscape.org) 1.x on macOS. It creates a disk image (otherwise referred to as "the toolset") that contains all dependencies so that Inkscape's CI can focus on building the app.

## Under the hood

The build system being used is [JHBuild](https://gitlab.gnome.org/GNOME/jhbuild) with a custom moduleset based off [gtk-osx](https://gitlab.gnome.org/GNOME/gtk-osx). If you have never heard about these two, take a look at [GTK's documentation](https://www.gtk.org/docs/installations/macos/); it is important to understand that this is neither Homebrew nor MacPorts. But don't worry, in the end it's just another orchestration tool to perform "configure; make; make install" and manage dependencies.

## Building mibap ("the toolset")

### Prerequisites

- A __clean environment__ is key. This is the most inconvenient requirement as it will likely conflict with how you are currently using your Mac, but it is vital.
  - Software and libraries - usually installed via package managers like Homebrew, MacPorts, Fink etc. - are known to cause problems depending on installation prefix. You cannot have software installed in the following locations:
    - `/usr/local`
    - `/opt/homebrew`
    - `/opt/local`
  - Uninstall Xquartz.
  - Use a dedicated user account to avoid any interference with the environment.
    - No customizations in dotfiles like `.profile`, `.bashrc` etc.

- There are __version recommendations__ based on known working setups, targeting the minimum supported OS versions (see [`sys.sh`](etc/jhb.conf.d/sys.sh)).
  - macOS Monterey 12.6
  - Xcode 13.x
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

1. Build the toolset.

   ```bash
   ./build_toolset.sh
   ```

   This will
   - build everything in your `$WRK_DIR`
   - take some time!

You'll likely see warnings during the build - that's normal. Some of them cannot be avoided, others are there to point out where you might be deviating from the recommended setup (e.g. using a different macOS version).

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

1. Install the toolset.

   ```bash
   ./install_toolset.sh
   ```

   This will

   - download the latest toolset [release](https://github.com/dehesselle/mibap/releases) (about 1.1 GiB) to `/Users/Shared/work/repo`
   - mount the (read-only) toolset to `/Users/Shared/work/mibap-0.63`
   - union mount a ramdisk (3 GiB) on top `/Users/Shared/work/mibap-0.63`

   The mounted volumes won't show up in Finder but you can see them using `diskutil list`. You can use `uninstall_toolset.sh` to eject them later.  
   _(Version numbers are subject to change.)_

1. Set `INK_DIR` to your clone of Inkscape's repository and start the build.

   ```bash
   # Clone Inkscape's sources if you haven't done this yet:
   # git clone --recurse-submodules https://gitlab.com/inkscape/inkscape $HOME/inkscape
   export INK_DIR=$HOME/inkscape
   ./build_inkscape.sh
   ```

   This will
   - build and install Inkscape (unpackaged) to `/Users/Shared/work/mibap-0.63`
   - create `Inkscape.app` and `Inkscape.dmg` in `/Users/Shared/work/mibap-0.63`.

## Contact

If you want to reach out, join [#team_devel_mac](https://chat.inkscape.org/channel/team_devel_mac) on Inkscape's RocketChat.

## Credits

The mibap icon uses a [red apple](https://openclipart.org/detail/190698/apple-with-bite) and [gears](https://openclipart.org/detail/176293/meshed-gears) from [Openclipart](https://openclipart.org), licensed under [CC0-1.0](https://spdx.org/licenses/CC0-1.0.html).

## License

[GPL-2.0-or-later](LICENSE)
