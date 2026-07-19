{pkgs, ...}: {
  # AMD dGPU. hardware.graphics.{enable,enable32Bit} is set in profiles/desktop.nix.
  boot.initrd.kernelModules = ["amdgpu"];
  services.xserver.videoDrivers = ["modesetting"];

  hardware.graphics.extraPackages = with pkgs; [
    vulkan-validation-layers
    libglvnd
    mesa
  ];

  environment.sessionVariables = {
    __EGL_VENDOR_LIBRARY_DIRS = "/run/opengl-driver/share/glvnd/egl_vendor.d";
    LIBGL_DRIVERS_PATH = "/run/opengl-driver/lib/dri";
    VK_LOADER_LAYERS_DISABLE = "VK_LAYER_VALVE_steam_overlay:VK_LAYER_VALVE_steam_fossilize";
  };
  environment.variables.VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json";
}
