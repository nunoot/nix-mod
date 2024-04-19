Nix configuration for single GPU passthrough, without the need for GPU reset scripts.

### Motivation
My graphics card has issues with the traditional GPU reset script method, so instead I'm using my configuration to create Nix specialisations for booting into a VM, without the need to load a DE/WM (Desktop Environment/Window Manager). 

### How it works
After creating your first specialisation for a VM (as outlined in example.nix), your specialisation will appear as a boot target in your boot menu.
When booting into this specialisation:
 - Your host machine will boot first (with the required kernel parameters set in pci.nix), opening a TTY and auto logging into the specified user (virtualisation.autoStart.user).
 - A virsh command will be ran by the user, to start your specified VM (virtualisation.autoStart.vm).
 - Your VM boots, and your blacklisted PCI devices are available to be used, without the need to reset them.

### Setup
I won't be going into much detail in this setup, instead I'd recommend you read the appropriate sections of another guide, such as the guide on the [Arch Wiki](https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF).

This guide assumes you've already installed a hypervisor, such as Virt Manager.
If you don't understand what to do, make sure to cross-reference these steps with another guide:
 - Before anything else, make sure you have both virtualisation and IOMMU enabled in your BIOS.
 - Find the PCI device ids (e.g 10de:13c2) of your graphics card, and any other devices that will need to be blacklisted from the host.
 - Copy from the example.nix file, then set virtualisation.passthrough.ids to the said PCI device ids (as a comma separated string).
 - Set the appropriate vm name and user via virtualisation.autoStart.vm and virtualisation.autoStart.user, respectively.
 - Create your VM if you haven't already, making sure to use OVMF.
 - Attach any PCI devices you need to your VM via it's settings.
 - Make sure you still have some way to boot into your host machine (I'd recommend only putting VMs in specialisations).
 - Run `nixos-rebuild switch`, then reboot your machine and try booting into a VM.
 - If everything worked, you should first see your host boot into a TTY, then shortly after boot into your VM.
