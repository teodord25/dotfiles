{pkgs, ...}: {
  imports = [
    ../pkgs/gaming-tools.nix
  ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
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

  programs.gamemode.enable = true;

  # AMD GPU specific settings
  boot.initrd.kernelModules = ["amdgpu"];
  services.xserver.videoDrivers = ["modesetting"];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      vulkan-validation-layers
      libglvnd
      mesa
    ];
  };

  # TODO: I might not need these anymore
  # vulkan and graphics env vars
  environment.sessionVariables = {
    __EGL_VENDOR_LIBRARY_DIRS = "/run/opengl-driver/share/glvnd/egl_vendor.d";
    LIBGL_DRIVERS_PATH = "/run/opengl-driver/lib/dri";
    VK_LOADER_LAYERS_DISABLE = "VK_LAYER_VALVE_steam_overlay:VK_LAYER_VALVE_steam_fossilize";
  };

  environment.variables.VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json";
}
