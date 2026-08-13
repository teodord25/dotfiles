{pkgs, ...}: {
  # Desktop tuned for gaming: no CPU power saving, newer kernel, and the
  # sysctl knobs games actually trip over. Gaming host only — the work
  # laptop wants thermald + default governor instead.

  boot.kernelPackages = pkgs.linuxPackages_zen;

  powerManagement.cpuFreqGovernor = "performance";

  boot.kernel.sysctl = {
    # some titles (CS2, Star Citizen, ...) blow past the default mmap limit
    "vm.max_map_count" = 2147483642;
    # don't throttle games that trip split locks (several D3D->vk titles do)
    "kernel.split_lock_mitigate" = 0;
  };

  # Optional extra few %: disable CPU vulnerability mitigations.
  # Reasonable on a single-user gaming box, your call:
  # boot.kernelParams = ["mitigations=off"];
}
