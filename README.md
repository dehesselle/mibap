# mibap - macOS Inkscape build and package

This repository is the development platform for building and packaging [Inkscape](https://inkscape.org) 1.0 (currently in alpha, Git master branch) on macOS. The scripts herein are targeted to be run on a dedicated build machine, not on your regular day-to-day machine.

## Requirements

_In some regards it would've been more fair if this section was called "recommendations" instead, but that would only encourage carelessness or deviating from a known-good setup._

- Use a __dedicated, clean macOS installation__ as build machine. "clean" as in "freshly installed + Xcode". Nothing more, nothing less.
  - Especially no MacPorts, no Fink, no Homebrew, ... because they could interfere with the build system we're using.
  - macOS 10.11.6 with Xcode 8.2.1.
  - macOS 10.11 SDK from Xcode 7.3.1
    - Place it inside your `Xcode.app` and re-symlink to make look as follows:

      ```bash
      elcapitan:SDKs rene$ pwd
      /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs
      elcapitan:SDKs rene$ ls -lah
      total 8
      drwxr-xr-x  5 root  wheel   170B 20 Jun 12:23 .
      drwxr-xr-x  5 root  wheel   170B 15 Dez  2016 ..
      lrwxr-xr-x  1 root  wheel    15B 20 Jun 12:23 MacOSX.sdk -> MacOSX10.11.sdk
      drwxr-xr-x  5 root  wheel   170B 21 Okt  2020 MacOSX10.11.sdk
      drwxr-xr-x  5 root  wheel   170B 17 Sep  2017 MacOSX10.12.sdk.disabled
      ```

- __Use a dedicated user account__ unless you're prepared that these scripts will delete and overwrite your data in the following locations:  
_(based on default configuration)_

    ```bash
    $HOME/.cache               # will be linked to $TMP_DIR
    $HOME/.config/jhbuildrc*   # will be overwritten
    $HOME/.profile             # will be overwritten
    ```

- __16 GiB RAM__, since we're using a 9 GiB ramdisk to build everything.
  - Using a ramdisk speeds up the process significantly and avoids wearing out your SSD.
  - You can choose to not use a ramdisk by overriding `RAMDISK_ENABLE=false` in a e.g. `021-custom.sh` file.
  - The build environment takes up ~6.1 GiB of disk space, the Inkscape Git repository ~1.6 GiB. Subject to change and YMMV.
- somewhat decent __internet connection__ for all the downloads

## Usage

Clone this repository to your build machine. You can either run all the executable scripts that have a numerical prefix yourself and in the given order (`1nn`, `2nn` - not the `0nn` ones), or, if you're feeling bold, use

```bash
./build_all.sh
```

to have everything run for you. If you are doing this the first time, my advice is to do it manually and step-by-step first to see if you're getting through all of it without errors.

Except for the the few things below `$HOME`, all the action takes place below `$WRK_DIR`. This allows for painless re-executability and keeps the host OS as clean as possible. For example, you can just eject the ramdisk and start over.

Once the whole process finishes, you'll find `Inkscape.app` in your `$ARTIFACT_DIR`.

### known issues

- If you're logged in to the desktop (instead of doing everything headless via ssh), you'll get popups asking to install Java. It's triggered by at least `gettext` and `cmake` and can be safely ignored.
- `gettext` can fail during checkout. I haven't figured out why. Choose `Rerun phase checkout` and it continues.
- `fontconfig` fails during build. Choose `Start shell`, run
  
  ```bash
  rm .jhbuild-srcdir/src/fcobjshash.h; exit
  ```

  and then `Rerun phase build`.

## Status

This project is still a work-in-progress (hence 0.x version) with regular merges to Inkscape master (see `packaging/macos` in [Inkscape's repository on GitLab](https://gitlab.com/inkscape/inkscape)).

### History

If you're interested in how this all started, checkout a version below `v0.7` and take a look at `DIARY.md` which served as readme in the beginning. Also, older (now discarded) scripts can be found checking out the `legacy` tag.

### Contact

If you want to reach out, join `#team_devel_mac` on [Inkscape's RocketChat](https://chat.inkscape.org/).

## License

[GPL](LICENSE)
