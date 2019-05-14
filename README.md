# mibap - macOS Inkscape build and package

This repository is the development platform for building and packaging [Inkscape](https://inkscape.org) 1.0 (currently in alpha, Git master branch) on macOS. The scripts herein are targeted to be run on a dedicated build machine, not on your regular day-to-day machine.

## Requirements

_It would've been more fair if this section was called "recommandations" instead, but that would only encourage carelessness._

- Use a __dedicated, clean macOS installation__ as build machine. "clean" as in "freshly installed + Xcode CLI tools". Nothing more, nothing less.
  - Especially no MacPorts, no Fink, no Homebrew, ... because they could interfere with the build system we're using.
  - macOS 10.13.6 with Xcode 10.1.
    - These scripts are being developed and used using said versions.
    - Newer versions might work but haven't been tested.
  - A full Xcode installation won't hurt, but is not required.
- __Use a dedicated user account__ unless you're prepared that these scripts will delete and overwrite your data in the following locations:  
_(comments based on default configuration)_

    ```bash
    $HOME/.cache       # will be symlinked to $WRK_DIR/tmp
    $HOME/.local       # will be symlinked to $WRK_DIR/opt
    $HOME/.profile     # will be overwritten
    ```

- __16 GiB RAM__, since we're using a 9 GiB ramdisk to build everything.
  - Using a ramdisk speeds up the process significantly and avoids wearing out your ssd.
  - You can choose to not use a ramdisk by overriding `RAMDISK_ENABLE=false` in a e.g. `021-custom.sh` file.
  - The build environment takes up ~6.1 GiB of disk space, the Inkscape Git repository ~1.6 GiB. Subject to change and YMMV.
- somewhat decent __internet connection__ for all the downloads

## Usage

Clone this repository to your build machine. Run

```bash
./build_all.sh
```

from inside the cloned repository. This will execute the whole suite of scripts, one after another.

All the action takes place inside the ramdisk. A few locations do have to be redirected/symlinked to the ramdisk (that is what the above warning "...these scripts will delete and overwrite your data..." is about) and your `.profile` just gets overwritten to set `PATH` and nothing more. The good thing about this is the painless re-executability and keeping the host OS clean (mostly clean - a few configuration files below `$HOME` do remain) - just throw away the ramdisk and start over.

Once the whole process finishes, you'll find `Inkscape.app` in your `/work/artifacts` or `$HOME/work/artifacts` folder, depending on your configuration.

### known issues

- If you're logged in to the desktop (instead of doing everything headless via ssh), you'll probably get a popup asking to install Java. It's triggered by `gettext`'s configuration (and at least one other package) and can be safely ignored.
- `gettext` can produce an error during checkout. Choose `Rerun phase checkout` and it continues.

## Status

This project is still a work-in-progress (hence 0.x version) with regular merges to Inkscape master (see `packaging/macos` in [Inkscape's repository on GitLab](https://gitlab.com/inkscape/inkscape)).

### History

If you're interested in how this all started, checkout a version below `v0.7` and take a look at `DIARY.md` which served as readme in the beginning. Also, older (now discarded) scripts can be found checking out the `legacy` tag.

## License
[GPL](LICENSE)
