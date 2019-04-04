# mibap - macOS Inkscape build and package

This repository contains my efforts in regards to building and packaging [Inkscape](https://inkscape.org) 1.0 (currently in alpha, Git master branch) on macOS. The scripts herein are targeted to be run on a dedicated build machine, not on your regular day-to-day machine.

## Requirements

- Use a __dedicated, clean macOS installation__ as build machine. "clean" as in "freshly installed + Xcode CLI tools". Nothing more, nothing less.
  - Especially no MacPorts, no Fink, no Homebrew, ... because they could interfere with the build system we're using.
  - macOS 10.13.6 with Xcode 10.1.
    - Other versions might work but haven't been tested.
  - A full Xcode installation won't hurt, but is not required.
- __Use a dedicated user account__ unless you're prepared that these scripts will delete and overwrite your data in the following locations:  
_(comments based on default configuration)_

    ```bash
    $HOME/.cache       # will be symlinked to $HOME/work/tmp
    $HOME/.local       # will be symlinked to $HOME/work/opt
    $HOME/.profile     # will be overwritten
    $HOME/Source       # will be symlinked to $HOME/work/opt/src
    ```

- __16 GiB RAM__, since we're using a 10 GiB ramdisk to build everything.
  - Using a ramdisk speeds up the process significantly and avoids wearing out your ssd.
  - You can choose to not use a ramdisk by overriding `RAMDISK_ENABLE=false` in a e.g. `011-custom.sh` file.
  - The build environment takes up ~6.5 GiB of disk space, the Inkscape Git repository ~1.8 GiB. Subject to change and YMMV.
- somewhat decent __internet connection__ for all the downloads

## Usage

Clone this repository to your build machine. Run

```bash
./build_everything.sh
```

from inside the cloned repository. This will execute the whole suite of scripts, one after another.

All the action takes place inside the ramdisk. A few locations do have to be redirected/symlinked to the ramdisk (that is what the warning above "...these scripts will delete and overwrite your data..." is about) and your `.profile` just gets overwritten to set `PATH` and nothing more. The good thing about this is the painless re-executability and keeping the host OS clean - just throw away the ramdisk and start over.

Once the whole process finishes, you'll find `Inkscape.app` in your `Desktop` folder.

### known issues

- If you're logged in to the desktop (instead of doing everything headless via ssh), you'll probably get a popup asking to install Java. It's triggered by `gettext`'s configuration and can be safely ignored.
  - FIXME: `gettext` can produce an error during checkout. Choose `Rerun phase checkout` and it continues.

## Status

As of v0.1, a working application bundle of Inkscape can be built. But this is only the starting point. There are still a lot of things missing/left to optimize, this is a work-in-progress.  
At some point development in this repository may cease and be continued in [Inkscape's repository on GitLab](https://gitlab.com/inkscape/inkscape).

### History

If you're interested in how this all started, check the former readme, now renamed to [DIARY.md](DIARY.md). Older (now discarded) scripts can be found checking out the `legacy` tag (it points to the last commit prior to `v0.1`).
