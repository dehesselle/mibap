# packages

A package is a file that contains everything regarding a specific piece of software or functionality to be sourced by other scripts. In terms of modulariziation and encapsulation, this is the preferred approach, as a package contains everything that otherwise would be scattered accross `020-vars.sh`, the `funcs` folder and possible other locations as well.

However, this approach cannot be applied to everything here without introducing new challenges and complications, therefore we're not forcing it. For now, only those parts that can be easily moved out of the global files and put into its own specific file (package) will be refacatored into a package.

## dependencies

Packages are to be sourced after variables and functions so they can make use of them. This will be taken care of automatically since we source files in ascending order.
