# JHBuild module set

This module set is an offspring of [gtk-osx](https://gitlab.gnome.org/GNOME/gtk-osx). It differs from its "spiritual upstream" as follows:

- Remove any software packages that we don't need to improve maintainability.
- Update packages as required, but don't needlessly divert from upstream. This way we can still benefit from using a largely identical base configuration in terms of stability, required patches etc.
- Keep the file layout mostly intact so diff'ing with upstream remains helpful.
- Inkscape specific packages area added to `inkscape.modules`.
- Use `inkscape.modules` as entry point, not `gtk-osx.modules`.
- Do not use a virtual Python environment for JHBuild as we don't aim to support as many different configurations/systems as upstream. We benefit from a largely simplified setup procedure in comparison to upstream.
- We use patches from local instead remote locations.
