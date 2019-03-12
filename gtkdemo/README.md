# GTK demo examples

## Prerequisites
- setup build environment with `setup_jhbuild_env.sh`
- enter build environment with `jhbuild shell`

## C

```bash
# BIN_DIR=??? # <- set value from setup_jhbuild_env.sh
gcc gtk3-demo.c $(pkg-config --libs --cflags gtk+-3.0) -o $BIN_DIR/gtk3-demo
gtk-mac-bundler gtk3-demo.bundle
```

## C++

```bash
# BIN_DIR=??? # <- set value from setup_jhbuild_env.sh
g++ -std=c++14 gtk3mm-demo.cpp $(pkg-config --libs --cflags gtkmm-3.0) -o $BIN_DIR/gtk3mm-demo
gtk-mac-bundler gtk3mm-demo.bundle
```

## Resources

- C/C++ programs and instructions taken from https://riptutorial.com/gtk3, licensed under [CD BY-SA 3.0](https://creativecommons.org/licenses/by-sa/3.0/).
- Examples and files for bundling taken from [gtk-mac-bundler](https://gitlab.gnome.org/GNOME/gtk-mac-bundler).

