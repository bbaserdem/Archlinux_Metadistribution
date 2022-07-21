# Homestation

This file contains information regarding my Homestation.
My Homestation; the only reason this is not a physical PC is because I'm mobile.
Here is the [phoronix thread](https://www.phoronix.com/forums/forum/hardware/general-hardware/961327-asus-rog-strix-gl702zc).

# Fan Control

[This phoronix post](https://www.phoronix.com/forums/forum/hardware/general-hardware/961327-asus-rog-strix-gl702zc?p=1054602#post1054602) has info on how to set up fans;

* NBFC is the best bet; since this is a gaming computer.
* The `/opt/nbfc/Plugins/StagWare.Plugins.ECSysLinux.dll` needs to be removed to apply the config.

# CPU crashes

CPU crashes; probably hardware fault.

* [StackExchange](https://serverfault.com/questions/858884/spontaneous-reboot-machine-check-events-amd-ryzen) says disable SMT or OpCache in BIOS.
* [Gentoo Forums](https://forums.gentoo.org/viewtopic-t-1061546.html); bit long read.
* [This kill script](https://github.com/suaefar/ryzen-test) should help troubleshoot.

# Kernel

[Here is a config; but for old linux version.](https://notabug.org/hp/linux-gl702zc)
