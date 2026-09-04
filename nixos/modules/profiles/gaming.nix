{pkgs, ...}: {
  # Everything game-related lives here; only the gaming host imports it.

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;

    extraCompatPackages = [pkgs.proton-ge-bin];
    extraPackages = with pkgs; [mangohud];

    package = pkgs.steam.override {
      extraPkgs = pkgs:
        with pkgs; [
          xorg.libXcursor
          xorg.libXi
          libpng
          libpulseaudio
          vulkan-loader
        ];
    };
  };

  # micro-compositor for games; also the HDR path:
  # launch options -> gamescope --hdr-enabled -f -- %command%
  programs.gamescope.enable = true;
  # capSysNice = true; # nicer frame pacing, but known to break gamescope
  #                    # when launched from inside Steam's FHS env — test first

  # `gamemoderun %command%` in Steam launch options
  programs.gamemode = {
    enable = true;
    settings = {
      general.renice = 10;
      gpu = {
        apply_gpu_optimisations = "accept-responsibility";
        gpu_device = 0;
        amd_performance_level = "high"; # pin GPU clocks while a game runs
      };
    };
  };

  environment.systemPackages = with pkgs; [
    mangohud # `mangohud <cmd>` outside Steam too
    protontricks
    wine64
    mono
    steam-run
    vintagestory
  ];

  services.hardware.openrgb.enable = true;
  services.hardware.openrgb.motherboard = "amd";
}
