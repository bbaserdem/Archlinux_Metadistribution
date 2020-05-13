# ZIMFW Pkgbuild;

I'll document what is happening in the install script when run with the 
'manual' installation instructions; to try to package things.

Auto installation is not an option as it FUCKING MODIFIES existing zconf files,
without user knowledge.

# Notes

The sourced files, by zsh, are in this order;

* `/etc/zsh/zshenv` (Must set ZDOTDIR here)
* `$ZDOTDIR/.zshenv` (Most set variables are unavailable here)
* `/etc/zsh/zprofile` (Sources /etc/profile->/etc/profile.d/\*) (Lot of variables set here)
* `$ZDOTDIR/.zprofile` (Sources XDG\_CONFIG\_HOME/profile)
* !`/etc/zsh/zshrc` (For interactive shell; sets spaceship prompt)
* !`$ZDOTDIR/.zshrc` (For interactive shell; in zim, calls init.zsh which uses .zimrc)
* !`/etc/zsh/zlogin` (For login shell)
* !`$ZDOTDIR/.zlogin` (For login shell)
* !`$ZDOTDIR/.zlogout` (For login shell; on exit!)
* !`/etc/zsh/zlogout` (For login shell; on exit!)

# Installation

It seems configuration is split into two directories

* **ZDOTDIR**: I think only a `.zimrc` is expected here.
* **ZIM_HOME**: This is where the installation happens in.

## Templates

You would need the `zimfw/install` repo; the files `src/templates` detail ideal
installation conditions.
Installer suggests putting these into `ZDOTDIR/` as *dotfiles* like the zsh way.

* **zshrc**: Does not need any compile-time info here tbh, probably ignorable.
The only important lines here is in the initialize modules section.
Which calls the `zimfw.zsh` with the `init` argument. (With quiet flag)
* **zshenv**: Sets `ZIM_HOME` to defaults to either `~/.zim` or `${ZDOTDIR}/.zim`
We would customize this to `/usr/share/zimfw`.
* **zlogin**: This sources `ZIM_HOME/login_init.zsh` which is sensible
* **zimrc**: First problem starts here.
The installer searches for SPECIFICALLY `.zimrc` in `ZDOTDIR`; thus a global
configuration at `/etc/zsh/zimrc` is going to prove difficult.

## Installer
The one in `zimfw/install` repo (as `install.zsh`) MODIFIES zconfig files;
don't use it for installation ever!
The installer is actually found in the main (`zimfw/zimfw`) repo as `zimfw.zsh`.

Does the following steps when sourced with the `install` flag.

* Sets readonly version var `_zversion` and help text `zusage`.
* Preallocates local vars `ztool` `_zmodule_xargs`
* Preallocates local arrays `_zdisableds` `_zmodules` `_zfpaths` `_zfunctions` `_zscripts`
* Preallocates local int `_zprintlevel` as 1
* I think `(( # ))` expands to number of arguments passed.
* Sets a complicated string command on `ztool`
* Sources `ZDOTDIR/.zimrc` (using the `_zimfw_source_zimrc`),
which should call `zmodule` function on all requested modules!
* Each invocation of zmodule HAS to be called from `ZDOTDIR/.zimrc`
* And adds some esotheric stuff to `_zmodules_xargs`
* Runs the `ztool` string on all the different `_zmodules_xargs`,
which clones all the usable modules to `ZDOTDIR/modules`
* Reduces `_zprintlevel`
* Resources `ZDOTDIR/.zimrc` again.
* Runs `_zimfw_build`; which runs the substring labeled functions.
* `_zimfw_build_init` creates an appropriate `ZIM_HOME/init.zsh`
* `_zimfw_build_login_init` creates an appropriate `ZIM_HOME/login_init.zsh`
* Runs `_zimfw_compile`; which sources `ZIM_HOME/login_init.zsh`
* Sourcing `ZIM_HOME/login_init.zsh` compiles all the (dotted) zsh files stuff
and all zsh files (modules, prompts, etc) under ZIM_HOME.

# Plan

So installation should only take a few steps;

* Put templates into a temporary ZDOTDIR directory as dotfiles. `${pkgdir}/usr/share/doc/zimfw`
* Modify templates for a maximum set of modules.
* Run installer with 

