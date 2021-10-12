# JHBuild module set

This module set is an offspring of [gtk-osx](https://gitlab.gnome.org/GNOME/gtk-osx). It differs from its "spiritual upstream" as follows:

- Remove any software packages that we don't need to simplify maintainability.
- Update packages as required, but don't needlessly divert from upstream. This way we can still benefit from using a largely identical base configuration in terms of stability, required patches etc.
- Keep the file layout mostly intact so diff'ing and keeping up with upstream is painless.
- Add Inkscape specific packages to `inkscape.modules`.
- Use `inkscape.modules` as entry point, not `gtk-osx.modules`.
- Use JHBuild from upstream and set it up ourselves, we don't use `gtk-osx-setup.sh`.
- Remove and/or change some parts of jhbuildrc.
