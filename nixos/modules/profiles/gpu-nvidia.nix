{pkgs, ...}: {
  # Intel iGPU + Nvidia dGPU laptop (PRIME offload).
  # hardware.graphics.{enable,enable32Bit} is set in profiles/desktop.nix.
  boot.initrd.kernelModules = ["i915"];
  services.xserver.videoDrivers = ["nvidia"];

  hardware.graphics.extraPackages = with pkgs; [
    intel-media-driver
    intel-compute-runtime
    vpl-gpu-rt
  ];

  hardware.nvidia = {
    modesetting.enable = true;
    open = true; # RTX A2000 supports the open kernel module
    prime = {
      offload.enable = true;
      offload.enableOffloadCmd = true; # gives you `nvidia-offload` command
      intelBusId = "PCI:0:2:0"; # check with: lspci | grep -E "VGA|3D"
      nvidiaBusId = "PCI:1:0:0"; # check with: lspci | grep -E "VGA|3D"
    };
  };
}
