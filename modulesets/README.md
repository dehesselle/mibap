# JHBuild module set

The module sets prefixed with `gtk-osx` are customized copies from [gtk-osx](https://gitlab.gnome.org/GNOME/gtk-osx). They differ from their upstream versions as follows:

- Remove any module that we don't need to simplify maintainability.
- Update a few select modules to other/newer versions, but don't needlessly divert from upstream. This way we can still benefit from using a largely identical base configuration in terms of stability, required patches etc.

The module set `inkscape.modules` has been created from scratch to manage Inkscape's dependencies that are not part of [gtk-osx](https://gitlab.gnome.org/GNOME/gtk-osx).
