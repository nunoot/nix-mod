{ config, ... }:

{
  imports = [
    ./pci.nix
  ];

  # Make sure to leave a way to access your host, for example, using the main configuration as the host, or creating an extra specialisation for the host.

  # Set this to an existing user of your choice.
  virtualisation.autoStart.user = "user";

  specialisation = {
    example.configuration.virtualisation = {
      passthrough.enable = true;
      # Set the ids of the PCI devices to be blacklisted from the host, namely your GPU.
      passthrough.ids = "xxxx:aaaa,xxxx:bbbb";
      # Set the name of the VM to be started when booting into this specialisation.
      autoStart.vm = "win10";
    };
  };
}
