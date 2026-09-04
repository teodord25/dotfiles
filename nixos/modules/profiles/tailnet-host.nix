{config, ...}: {
  services.openssh = {
    enable = true;
    openFirewall = false;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # whole tailnet is trusted on this host
  networking.firewall.trustedInterfaces = ["tailscale0"];

  users.users.${config.main-user.userName}.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAA... teodor@teodor-work-nixos"
  ];
}
