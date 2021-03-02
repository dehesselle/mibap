# packages

A package is a file that contains everything regarding a specific piece of software or functionality to be sourced by other scripts. In terms of modularization and encapsulation, this is the preferred approach, as a package contains everything that otherwise would be scattered accross multiple files and location (e.g. `020-vars.sh`, `funcs` folder).

However, this approach cannot be applied to everything without introducing new challenges and complications, therefore we're not forcing it. For now, only those parts that can be easily moved out of the different global files and locations will be refacatored into a packages.

## dependencies

Packages are to be sourced after variables and functions so they are allowed to depend on them. This will be taken care of automatically since we source files in ascending order.
