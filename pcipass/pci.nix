{ config, pkgs, lib, ... }:

with lib;
let cfg = config.virtualisation;

in { 
  options.virtualisation = {
    passthrough.enable = mkEnableOption "PCI Passthrough";
    passthrough.ids = mkOption {
      type = types.str;
      example = "0000:0000,0000:ffff";
      description = "PCI device ids to be blacklisted from the host";
    };

    autoStart.enable = mkEnableOption "VM Auto Start";
    autoStart.vm = mkOption {
      type = types.str;
      example = "win10";
      description = "Name of the VM to auto start";
    };
    autoStart.user = mkOption {
      type = types.str;
      example = "user";
      description = "User used to run virsh start commands";
    };
  };

  config = {
    # --- Virt Manager

    # Install required packages.
    environment.systemPackages = with pkgs; [
      virt-manager
      # pciutils isn't required, but may be useful during setup.
      pciutils
    ];

    # Enables the libvirt daemon, allowing for management of VMs, with the virsh command for example.
    virtualisation.libvirtd.enable = true;
    # Supposedly prevents VMs from restarting after a shutdown (https://search.nixos.org/options?query=virtualisation.libvirtd.onBoot)?
    virtualisation.libvirtd.onBoot = mkDefault "ignore";
    # Disable VM suspend on shutdown.
    virtualisation.libvirtd.onShutdown = mkDefault "shutdown";
    # Adds backwards compatibility (I haven't tested this) for nix channels before 23.11 (https://nixos.wiki/wiki/Virt-manager).
    programs.dconf.enable = mkDefault true;

    # --- PCI Passthrough

    # Used to prevent the host from using the PCI device(s), as well as other vfio magic.
    # "vfio_virqfd" is no longer required as of linux kernel version 6.2 (https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF).
    boot.kernelModules = [ "vfio" "vfio_pci" "vfio_iommu_type1" "vfio_virqfd" ];
    # VMs using PCI passthrough should be set to boot with UEFI.
    # I don't know why UEFI is required, but OVMF is the UEFI implementation I see most used for PCI Passthrough VMs.
    virtualisation.libvirtd.qemu.ovmf.enable = true;

    # Enables IOMMU, which is required for PCI passthrough.
    # Also blacklists the host from using the specified PCI device ids.
    # Kernel parameters are not the only way to blacklist PCI devices, but I prefer this method.
    boot.kernelParams = mkIf cfg.passthrough.enable [ "amd_iommu=on" "iommu=pt" "vfio-pci.ids=${cfg.passthrough.ids}" ];

    # --- VM Auto Start

    # Gives the specified user permission to manage VMs via libvirt.
    users.groups.libvirtd.members = mkIf cfg.libvirtd.enable (mkIf cfg.autoStart.enable [ "${cfg.autoStart.user}" ]);

    # Enable autologin for the autoStart user.
    # This is required so that virsh commands to start the VMs can be ran without having to manually login.
    services.getty.autologinUser = mkIf cfg.autoStart.enable "${cfg.autoStart.user}";

    # Executes a script upon user activation (https://search.nixos.org/options?query=system.userActivationScripts), which then starts the VM via the virsh command.
    system.userActivationScripts = mkIf cfg.autoStart.enable {
      autoStartVM.text = ''
        ${pkgs.libvirt}/bin/virsh --connect qemu:///system start ${cfg.autoStart.vm}
      '';
    };
  };
}
