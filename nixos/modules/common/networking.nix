{ ... }:
{
  networking.networkmanager.enable = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  services.blueman.enable = true;

  services.printing.enable = true;

  # printer discovery stuff
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
}
