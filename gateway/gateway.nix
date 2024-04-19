{ config, ... }:

let internalInterface = "INTERFACE-HERE";

in {
  boot.kernel.sysctl."net.ipv4.conf.all.forwarding" = true;

  # Set up the internalInterface with a static IP.
  networking.interfaces."${internalInterface}".ipv4.addresses = [{
    # Feel free to change the internalInterface's static IP,
    # Though the dhcp-range of the DHCP server (dnsmasq) would have to be changed respectively.
    address = "10.0.0.1";
    prefixLength = 24;
  }];

  # Allow all incoming traffic from the internalInterface.
  # It would be a good idea to restrict any traffic that you don't require though.
  networking.firewall.trustedInterfaces = [ "${internalInterface}" ];

  networking.nat.enable = true;
  networking.nat.internalInterfaces = [ "${internalInterface}" ];

  # Set up a DCHP server on the internalInterface, to avoid manually setting up static IPs.
  services.dnsmasq.enable = true;
  services.dnsmasq.settings = {
    interface = internalInterface;
    # Feel free to change the DCHP range,
    # Though the static IP of the internalInterface would have to be changed respectively.
    dhcp-range = [ "10.0.0.2,10.0.0.254,24h" ];
  };
}
