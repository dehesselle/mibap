# macOS Inkscape build and package (mibap)

![GitHub badge](https://img.shields.io/badge/GitHub-100000?style=for-the-badge&logo=github&logoColor=white)
![GitHub build worfklow](https://github.com/dehesselle/mibap/workflows/build/badge.svg)
![GitHub release workflow](https://github.com/dehesselle/mibap/workflows/release/badge.svg)
![GitLab badge](https://img.shields.io/badge/GitLab-330F63?style=for-the-badge&logo=gitlab&logoColor=white)![GitLab master branch](https://gitlab.com/dehesselle/mibap/badges/master/pipeline.svg)

This repository is the development platform for building and packaging [Inkscape](https://inkscape.org) 1.x on macOS. Together with its [mirror on GitLab](https://gitlab.com/dehesselle/mibap) it creates a ready-to-use disk image (otherwise referred to as "the toolset"), containing all dependencies so that Inkscape's CI can focus on building the app.

![mibap_overview](https://github.com/dehesselle/mibap/wiki/mibap_overview.drawio.svg)

## Under the hood

The build system being used is [JHBuild](https://gitlab.gnome.org/GNOME/jhbuild) with a custom moduleset based off [gtk-osx](https://gitlab.gnome.org/GNOME/gtk-osx). If you have never heard about these two, take a look at [GTK's documentation](https://www.gtk.org/docs/installations/macos/); it is important to understand that this is neither Homebrew nor MacPorts. But don't worry, in the end it's just another orchestration tool to perform "configure; make; make install" and manage dependencies.

## Building mibap ("the toolset")

### Prerequisites

- A __clean environment__ is key. This is the most inconvenient requirement.
  - Software and libraries installed via package managers like Homebrew, MacPorts, Fink etc. are known to cause problems (usually: build failures) depending on installation prefix.
    - Clear out `/usr/local`.
    - Uninstall Xorg.
  - Use a dedicated user account to avoid any interference with the environment.
    - No customizations in dotfiles like `.profile`, `.bashrc` etc.

- There are __version recommendations__ based on a known working setup.
  - macOS Catalina 10.15.7
  - Xcode 12.4
  - macOS High Sierra 10.13 SDK (from Xcode 9.4.1)

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
   echo "WRK_DIR=$HOME/my_build_dir" > 005-customdir.sh
   ```

1. _(optional)_ Use a specific SDK (default: `xcodebuild -version -sdk macosx Path`).

   ```bash
   # Optional. Avoid spaces.
   echo "SDKROOT=$HOME/MacOSX10.13.sdk" > 005-sdkroot.sh
   ```

1. Build the toolset.

   ```bash
   ./build_toolset.sh
   ```

   This will
   - build everything in your `$WRK_DIR`
   - take some time!

## Building Inkscape

The easiest way to build Inkscape is using the precompiled toolset. The only downsinde is that you don't get to choose the build directory, you have to accept the default `/Users/Shared/work`.

<!-- markdownlint-disable MD024 -->
### Steps
<!-- markdownlint-enable MD024 -->

1. Clone this repository and `cd` into it. Checkout the latest tag, do not use master. Initialize and update the submodules.

   ```bash
   git clone https://github.com/dehesselle/mibap
   cd mibap
   # checkout tag with highest version number
   git checkout $(git tag | grep "^v" | sort -V | tail -1)
   git submodule init
   git submodule update
   ```

1. Install the toolset.

   ```bash
   ./install_toolset.sh
   ```

   This will

   - download the latest toolset [release](https://github.com/dehesselle/mibap/releases) (about 1.1 GiB) to `/Users/Shared/work/repo`
   - mount the (read-only) toolset to `/Users/Shared/work/<version>`
   - union mount a ramdisk (3 GiB) to `/Users/Shared/work/<version>`

   The mounted volumes won't show up in Finder but you can see them using `diskutil list`. You can use `uninstall_toolset.sh` to eject them later.

1. Build Inkscape.

   ```bash
   ./build_inkscape.sh
   ```

   This will
   - build and install Inkscape (unpackaged) to `/Users/Shared/work/<version>`
   - create `Inkscape.app` and `Inkscape.dmg` in `/Users/Shared/work/<version>`.

## Contact

If you want to reach out, join [#team_devel_mac](https://chat.inkscape.org/channel/team_devel_mac) on Inkscape's RocketChat.

## License

[GPL-2.0-or-later](LICENSE)
