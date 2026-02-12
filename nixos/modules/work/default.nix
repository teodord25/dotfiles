{pkgs, ...}: {
  imports = [
    ../personal/desktop.nix
  ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver # VAAPI driver
      intel-compute-runtime # OpenCL
      vpl-gpu-rt # intel VPL GPU runtime
    ];
  };

  boot.initrd.kernelModules = ["i915"]; # graphics driver
  services.xserver.videoDrivers = ["modesetting"];

  # work-specific configuration TBD
  # jb-specific tools, VPN, corporate settings and so on

  # set up simpler desktop environment

  # basic X11 setup maybe with i3 and so on
  # services.xserver.enable = true;
  # services.displayManager.sddm.enable = true;
  # services.libinput.enable = true;

  # xdg.portal.enable = true;
  # xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  # xdg.portal.config.common.default = "*";

  # laptop battery stuff
  # services.upower.enable = true;

  # You might want Hyprland for work too, or a different DE
  # Uncomment if you decide to use Hyprland at work:
  # programs.hyprland = {
  #   enable = true;
  #   xwayland.enable = true;
  # };

  # work-specific packages
  environment.systemPackages = with pkgs; [
    jetbrains-toolbox
    # god forbid ms teams
    # slack
    # IDEs and so on
  ];

  # corporate VPN or other work network requirements
  # networking.vpn...

  # maybe disable some stuff explicitly
}
