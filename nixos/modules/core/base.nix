{pkgs, ...}: {
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.gnome.gnome-keyring.enable = true;
  services.gnome.gcr-ssh-agent.enable = false;
  security.pam.services.login.enableGnomeKeyring = true;

  services.xserver = {
    displayManager = {
      startx.enable = true;
    };
  };

  programs.ssh = {
    startAgent = true;
    extraConfig = ''
      AddKeysToAgent yes
    '';
  };

  time.timeZone = "Europe/Belgrade";
  i18n.defaultLocale = "en_GB.UTF-8";

  # keyboard layout
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
    wireplumber.extraConfig."51-disable-hfp" = {
      "monitor.bluez.properties" = {
        "bluez5.roles" = [
          "a2dp_sink"
          "a2dp_source"
          "bap_sink"
          "bap_source"
        ];
      };
    };
  };

  nixpkgs.config.allowUnfree = true;
  programs.gnupg.agent.enable = true;

  services.mullvad-vpn.enable = true;

  # caps as ctrl / esc mapping
  services.kanata.enable = true;
  services.kanata.keyboards.default.config = ''
    (defsrc caps lctl)
    (defalias escctrl (tap-hold 100 100 esc lctrl))
    (deflayer base @escctrl lmet)
  '';

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    roboto
    source-sans-pro
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
  ];

  # install ghostty terminfo system-wide
  environment.etc."terminfo/x/xterm-ghostty".source = "${pkgs.ghostty}/share/terminfo/x/xterm-ghostty";
}
