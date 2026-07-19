{pkgs, ...}: {
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    extraCompatPackages = [pkgs.proton-ge-bin];
    localNetworkGameTransfers.openFirewall = true;

    extraPackages = with pkgs; [mangohud];

    package = pkgs.steam.override {
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
  };

  programs.gamemode.enable = true;

  environment.systemPackages = with pkgs; [
    wine64
    mono
    steam-run
  ];
}
