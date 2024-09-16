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

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Belgrade";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
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

  services.kanata.enable = true;
  services.kanata.keyboards.default.config = ''
    (defsrc caps)
    (defalias escctrl (tap-hold 100 100 esc lctrl))
    (deflayer base @escctrl)
  '';

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = ["nix-command" "flakes"];

  # On NixOS 24.05 or older, this option must be set:
  # sound.enable = false;

  # rtkit is optional but recommended
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.upower.enable = true;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  services.blueman.enable = true;

  environment.systemPackages = with pkgs; [
    git
    neovim
    vim
    wget
    nushell
    starship
    qemu
    quickemu

    nheko
    qbittorrent

    yazi
    mpv

    file

    cargo
    cliphist

    firefox
    bitwarden
    python3Full
    go
    pavucontrol
    act

    fastfetch
    eww

    mako
    libnotify
    swww

    rofi-wayland

    gcc

    discord

    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    nerdfonts

    fontforge-gtk

    binwalk

    tmux

    ripgrep

    wl-clipboard
    grim
    slurp

    steam-run
    p7zip

    hyprpicker

    nodejs_22
    kdePackages.kwallet

    android-studio
    lua-language-server
    nodePackages.typescript-language-server
    gopls
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "olm-3.2.16"
  ];

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    nerdfonts
    # liberation_ttf
    # fira-code
    # fira-code-symbols
    # mplus-outline-fonts.githubRelease
    # dina-font
    # proggyfonts
  ];

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-gtk];
  xdg.portal.config.common.default = "*";

  programs.hyprland.enable = true;

  # programs.xwayland.enable = true;

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
