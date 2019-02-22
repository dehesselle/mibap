# mibap - macOS Inkscape Build And Package
The Inkscape devs need help with compiling and packaging on macOS ("from source to dmg"). I want to help, so let's see how far we come. I'm saying "we" because this is not a singular person's effort, it's a joint effort. I want to take a look at and (hopefully) build upon what others have come up with. Ideally we can take this past the finish line, but if not, someone else will have the chance to pick up the torch.

This is an activity log and/or notepad of sorts. _(If successful, there will be scripts and stuff here that we can PR to Inkscape.)_

# 22.02.2019
- Homebrew formula is https://github.com/caskformula/homebrew-caskformula
  - a bit out of date
  - commentend on [Issue 75](https://github.com/caskformula/homebrew-caskformula/issues/75) asking for ipatch's current working build: [ipatch's work](https://github.com/ipatch/homebrew-us-05/blob/master/inkscape/inkscape-building-for-macOS.md)
- MacPorts portfile is https://github.com/macports/macports-ports/blob/master/graphics/inkscape/Portfile
  - based on last commit, seems pretty current

Next: build using ipatch's notes
