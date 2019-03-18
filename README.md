# mibap - macOS Inkscape build and package

This repository contains my efforts in regards to building and packaging Inkscape 1.0 (currently in alpha, Git master branch) on macOS. The scripts herein are targeted to be run on a dedicated build machine, not on your regular day-to-day machine.

_(The former readme of this repository has been moved to [DIARY.md](DIARY.md).)_

## Requirements

- Use a __dedicated, clean macOS installation__ as build machine. "clean" as in "freshly installed + Xcode (full setup)". Nothing more, nothing less.
  - Especially no MacPorts, no Fink, no Homebrew, ... because they could interfere with the build system we're using.
  - latest macOS 10.13.x / 10.14.x only
- __Do not use your regular Mac__ unless you're prepared that these scripts will delete and overwrite your data in the following locations:

    ```bash
    $HOME/.cache
    $HOME/.local
    $HOME/.profile
    $HOME/Source
    ```

- __16 GiB RAM__, since we're using a 8 GiB ramdisk to build everything
  - The Inkscape Git repository gets shallow-cloned. For a full clone, a 10 GiB ramdisk is needed.
- somewhat decent __internet connection__ for all the downloads

## Usage

Clone this repository to your build machine. Run

```bash
./run_everything.sh
```

from inside the cloned repository. This will execute the whole suite of scripts, one after another.

All the action takes place inside the ramdisk. A few locations do have to be redirected/symlinked to the ramdisk (that is what the warning above "...these scripts will delete and overwrite your data..." is about) and your `.profile` just gets overwritten to set `PATH` and nothing more. The good thing about this is the painless re-executability and keeping the host OS clean - just throw away the ramdisk and start over.

Once the whole process finishes, you'll find `Inkscape.app` in your `Desktop` folder.

### known issues

- On macOS 10.13, step `030` fails during configuration of `expat`. Open a shell (menu option `4`), manually configure via `./configure --prefix=$OPT_DIR`, then `exit` the shell and continue the build process (menu option `2`).

## Status

As of v0.1, a working application bundle of Inkscape can be built. But this is only the starting point. There are still a lot of things missing/left to optimize, this is a work-in-progress.
