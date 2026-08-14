{...}: {
  # AMD dGPU on the default open stack (amdgpu + mesa/RADV) — no extra
  # driver packages needed for GL or Vulkan.
  # hardware.graphics.{enable,enable32Bit} is set in profiles/desktop.nix.
  boot.initrd.kernelModules = ["amdgpu"]; # early KMS
  services.xserver.videoDrivers = ["modesetting"];

  # NOTE: the old VK_ICD_FILENAMES / VK_LOADER_LAYERS_DISABLE /
  # LIBGL_DRIVERS_PATH env-var pins were workarounds from the previous
  # machine. On a clean all-AMD box they are unnecessary (and disabling
  # the Valve layers kills the Steam overlay). Re-add only if something
  # actually misbehaves.

  # GPU control: fan curves, power limit, per-level clocks
  # overdrive is required or amdgpu refuses clock/power changes
  services.lact.enable = true;
  hardware.amdgpu.overdrive.enable = true;
}
