{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./main-user.nix
    inputs.home-manager.nixosModules.default
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.kernelModules = ["amdgpu"];

  services.printing.enable = true; # Enables CUPS printing service
  services.printing.drivers = [pkgs.hplip]; # Optional: Add drivers like HPLIP for HP printers

  services.avahi = {
    enable = true;
    nssmdns = true;
    openFirewall = true;
  };

  programs.nix-ld = {
    enable = true;
    package = pkgs.nix-ld-rs;
    libraries = with pkgs; [
      stdenv.cc.cc
      zlib
      # Add other libraries as needed
    ];
  };

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable networking
  networking.networkmanager.enable = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  services.blueman.enable = true;

  # hardware.bluetooth.settings = {
  #   General = {
  #     Enable = "Source,Sink,Media,Socket";
  #   };
  # };
  #
  # hardware.pulseaudio.enable = false;
  # security.rtkit.enable = true;
  # services.pipewire = {
  #   enable = true;
  #   alsa.enable = true;
  #   alsa.support32Bit = true;
  #   pulse.enable = true;
  #   wireplumber.configPackages = [
  #     (pkgs.writeTextDir "share/wireplumber/wireplumber.conf.d/10-bluez.conf" ''
  #       monitor.bluez.properties = {
  #         bluez5.roles = [ a2dp_sink a2dp_source bap_sink bap_source hsp_hs hsp_ag hfp_hf hfp_ag ]
  #         bluez5.codecs = [ sbc sbc_xq aac ldac ]
  #         bluez5.enable-sbc-xq = true
  #         bluez5.hfphsp-backend = "native"
  #       }
  #     '')
  #   ];
  # };

  time.timeZone = "Europe/Belgrade";

  i18n.defaultLocale = "en_GB.UTF-8";

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  programs.gnupg.agent.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };

  main-user.enable = true;
  main-user.userName = "bane";

  home-manager = {
    extraSpecialArgs = {inherit inputs;};
    users = {
      "bane" = import ./home.nix;
    };
  };

  virtualisation.docker.enable = true;

  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = ["bane"];

  services.kanata.enable = true;
  services.kanata.keyboards.default.config = ''
    (defsrc caps)
    (defalias escctrl (tap-hold 100 100 esc lctrl))
    (deflayer base @escctrl)
  '';

  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = ["nix-command" "flakes"];

  services.upower.enable = true;

  hardware.opentabletdriver.enable = true;

  # Enable X11
  services.xserver.enable = true;

  # Use i3 window manager
  # services.xserver.windowManager.i3.enable = true;

  # Set display manager (you can use SDDM, LightDM, etc.)
  services.displayManager.sddm.enable = true;

  # Ensure video drivers are set (adjust for your GPU)

  environment.variables.VK_ICD_FILENAMES = "/etc/vulkan/icd.d/radeon_icd.x86_64.json";

  # Input support
  services.libinput.enable = true;

  environment.systemPackages = let
    apps = import ../../pkgs/apps.nix {inherit pkgs;};
    cli-qol = import ../../pkgs/cli-qol.nix {inherit pkgs;};
    hypr = import ../../pkgs/hypr.nix {inherit pkgs;};
    lang = import ../../pkgs/lang.nix {inherit pkgs;};
    ls = import ../../pkgs/ls.nix {inherit pkgs;};
    tools = import ../../pkgs/tools.nix {inherit pkgs;};
  in (
    apps ++ cli-qol ++ hypr ++ lang ++ ls ++ tools ++ [pkgs.nodejs_22]
  );

  # Enable hardware graphics support
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.xserver.videoDrivers = ["amdgpu"];

  fonts.packages = with pkgs;
    [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
    ]
    ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues nerd-fonts);

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-gtk];
  xdg.portal.config.common.default = "*";

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  programs.xwayland.enable = true;

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
