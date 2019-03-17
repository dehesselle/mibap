# mibap - macOS Inkscape Build And Package

This repository contains my efforts in regards to building and packaging Inkscape on macOS. (The former readme of this has been moved to [DIARY.md](DIARY.md).) The scripts herein are targeted to be run on a dedicated build machine, not on your regular day-to-day machine.

## Requirements

- Use a __dedicated, clean macOS installation__ as build machine. "clean" as in "freshly installed + Xcode (full setup)". Nothing more, nothing less.
  - Especially no MacPorts, no Fink, no Homebrew, ... because they could interfere with the build system we're using.
- __Do not use your regular Mac__ unless you're prepared that these scripts will delete and overwrite your data in the following locations:

    ```bash
    $HOME/.cache
    $HOME/.local
    $HOME/.profile
    $HOME/Source
    ```

- __16 GiB RAM__, since we're using a 10 GiB ramdisk to build everything
- somewhat decent __internet connection__ for all the downloads

## Usage
Clone this repository to your build machine. Run

```
./run_everything.sh
```

from inside the cloned repository. This will execute all the necessary build steps one after another.



## Build status
Successfully run everything using
- macOS 10.14.3 (inkluding updates as of 17.03.2019)
- Xcode 10.x
