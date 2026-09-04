{config, ...}: {
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
  };

  networking.firewall.allowedUDPPorts = [config.services.tailscale.port];
  services.resolved.enable = true;
}
