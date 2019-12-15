# mibap - macOS Inkscape build and package

This repository is the development platform for building and packaging [Inkscape](https://inkscape.org) 1.0 (currently in beta, Git master branch) on macOS. The scripts herein are targeted to be run on a dedicated build machine, not on your regular day-to-day machine.

## Requirements

_These requirements have changed a few times over the course of development. So it would be more fair to call them "recommendations" instead, but I want to emphasize the importance of sticking to a known-good setup because of the huge number of moving parts involved._

- __A clean environment is key__. Ideally, you'd have a __dedicated, clean macOS installation__ (as in "freshly installed + Xcode") available as build machine.
  - Make sure there are no remnants from other build environments (e.g. MacPorts, Fink, Homebrew) on your system.  
    Rule of thumb: clear out `/usr/local`.
  - macOS 10.14.6 with Xcode 10.3.
  - OS X Mavericks 10.9 SDK from Xcode 6.4  
    `/Library/Developer/CommandLineTools/SDKs/MacOSX10.9.sdk`

- __Use a dedicated user account__ unless you're prepared that these scripts will delete and overwrite your data in the following locations:  
_(based on default configuration)_

    ```bash
    $HOME/.cache               # will be removed, then linked to $TMP_DIR
    $HOME/.local               # will be removed, then linked to $OPT_DIR
    ```

- __16 GiB RAM__, since we're using a 9 GiB ramdisk to build everything.
  - Using a ramdisk speeds up the process significantly and avoids wearing out your SSD.
  - You can choose to not use a ramdisk by overriding the configuration.

    ```bash
    echo "RAMDISK_ENABLE=false" > 021-vars-custom.sh
    ```

  - The build environment takes up ~6.1 GiB of disk space, the rest is buffer to be used during compilation and packaging. Subject to change and YMMV.

  - If you only want to build Inkscape and not the build environment itself, a 5 GiB ramdisk is sufficient. (Not all of the tarball's content is extracted.)

- somewhat decent __internet connection__ for all the downloads

## Usage

Clone this repository to your build machine. You can either run all the executable scripts that have a numerical prefix (>100) yourself and in the given order, or, if you're feeling bold, use

```bash
./build_all.sh
```

to have everything run for you. If you are doing this the first time, my advice is to do it manually and step-by-step first to see if you're getting through all of it without errors. Also mind the known issues below!

Except for the the few things below `$HOME`, all the action takes place below `$WRK_DIR`. This allows for painless re-executability and keeps the host OS as clean as possible. For example, you can just eject the ramdisk and start over.

Once the whole process finishes, you'll find `Inkscape.app` in your `$ARTIFACT_DIR`.

### known issues

- If you're logged in to the desktop, you'll get multiple popups asking to install Java. It's triggered by at least `gettext` and `cmake` and can be safely ignored.
- Sometimes packages fail to checkout successfully on the first try, I've had this happen frequently with `gettext`. Just choose `Rerun phase checkout` (option 1) to continue.

## Status

This project is still a work-in-progress (hence 0.x version) with regular merges to Inkscape master (see `packaging/macos` in [Inkscape's repository on GitLab](https://gitlab.com/inkscape/inkscape)).

### History

If you're interested in how this all started, checkout a version below `v0.7` and take a look at `DIARY.md` which served as readme in the beginning. Also, older (now discarded) scripts can be found checking out the `legacy` tag.

### Contact

If you want to reach out, join `#team_devel_mac` on [Inkscape's RocketChat](https://chat.inkscape.org/).

## License

[GPL](LICENSE)
