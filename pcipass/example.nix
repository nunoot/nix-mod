{ config, ... }:

{
  imports = [
    ./pci.nix
  ];

  # Set this to an existing user of your choice.
  virtualisation.autoStart.user = "user";
  # Set the ids of the PCI devices to be blacklisted from the host, namely your GPU.
  passthrough.ids = "xxxx:aaaa,xxxx:bbbb";

  specialisation = {
    example.configuration.virtualisation = {
      # Enabling virtualisation.passthrough.enable will blacklist your virtualisation.passthrough.ids from the host, allowing them to be used in a VM.
      # Be careful not to enable this configuration wide, as that would blacklist your PCI devices (i.e, your GPU) for all boot targets, leaving you with no way to boot into your host's DE/WM.
      passthrough.enable = true;
      # Enabling this will allow the system.userActivationScripts.autoStartVM script to run, starting the virtualisation.autoStart.vm VM.
      # If you'd like to use a different method of starting your VM at boot (or manually start your VM), feel free to disable this.
      autoStart.enable = true;

      # Set the name of the VM to be started when booting into this specialisation.
      autoStart.vm = "win10";
    };
  };
}
