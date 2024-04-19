Nix configuration for single GPU passthrough, without the need for GPU reset scripts.

My graphics card has issues with the traditional GPU reset script method, so instead I'm using my configuration to create Nix specialisations for booting into a VM, without the need of loading a DE/WM (Desktop Environment/Window Manager). Any of these specialisations can be selected as a boot target from my boot menu.

An example setup can be found in example.nix - I won't go into detail on how to find the ids for the PCI devices you want to blacklist, or how to attach said devices to your VM here though, since there are plenty of GPU passthrough guides already.
