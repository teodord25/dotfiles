{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./main-user.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.kernelModules = ["amdgpu"];

  services.printing.enable = true; # Enables CUPS printing service
  services.printing.drivers = [pkgs.hplip]; # Optional: Add drivers like HPLIP for HP printers

  services.zerotierone.enable = true;

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  programs.nix-ld = {
    enable = true;
    package = pkgs.nix-ld;
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

  programs.steam.package = pkgs.steam.override {
    extraPkgs = pkgs:
      with pkgs; [
        xorg.libXcursor
        xorg.libXi
        libpng
        libpulseaudio
        vulkan-loader
        vulkan-validation-layers
      ];
  };

  main-user.enable = true;
  main-user.userName = "bane";

  virtualisation.docker.enable = true;

  users.extraGroups.vboxusers.members = ["bane"];

  services.kanata.enable = true;
  services.kanata.keyboards.default.config = ''
    (defsrc caps)
    (defalias escctrl (tap-hold 100 100 esc lctrl))
    (deflayer base @escctrl)
  '';

  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  services.upower.enable = true;

  hardware.opentabletdriver.enable = true;

  # enable X11
  services.xserver.enable = true;

  # Set display manager (you can use SDDM, LightDM, etc.)
  services.displayManager.sddm.enable = true;

  # Ensure video drivers are set (adjust for your GPU)

  # Input support
  services.libinput.enable = true;

  environment.systemPackages = let
    apps = import ../../pkgs/apps.nix {inherit pkgs;};
    cli-qol = import ../../pkgs/cli-qol.nix {inherit pkgs;};
    hypr = import ../../pkgs/hypr.nix {inherit pkgs;};
    lang = import ../../pkgs/lang.nix {inherit pkgs;};
    ls = import ../../pkgs/ls.nix {inherit pkgs;};
    grammars = import ../../pkgs/grammars.nix {inherit pkgs;};
    tools = import ../../pkgs/tools.nix {inherit pkgs;};
  in (apps ++ cli-qol ++ hypr ++ lang ++ ls ++ grammars ++ tools ++ [pkgs.nodejs_22]);

  # Enable hardware graphics support
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      vulkan-validation-layers
      libglvnd
      mesa
    ];
  };

  programs.gamemode.enable = true;

  # Unify env vars (and disable Steam’s implicit layers globally)
  environment.sessionVariables = {
    __EGL_VENDOR_LIBRARY_DIRS = "/run/opengl-driver/share/glvnd/egl_vendor.d";
    LIBGL_DRIVERS_PATH = "/run/opengl-driver/lib/dri";
    NIXOS_OZONE_WL = "1";

    # Prevent Steam overlay/fossilize layers from loading into non-Steam apps
    VK_LOADER_LAYERS_DISABLE = "VK_LAYER_VALVE_steam_overlay:VK_LAYER_VALVE_steam_fossilize";
  };

  services.xserver.videoDrivers = ["amdgpu"];

  environment.variables.VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json";

  fonts.packages = with pkgs;
    [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      roboto
      source-sans-pro
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

  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
