# modules/virtualisation.nix
{pkgs, ...}: {
  boot.extraModprobeConfig = ''
    options kvm ignore_msrs=1
  '';

  # ---- libvirt / QEMU-KVM ----
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true; # software TPM — still here, unaffected by the change
      # ovmf block removed — firmware is now wired up automatically
    };
  };

  # SPICE USB passthrough/redirection for guests
  virtualisation.spiceUSBRedirection.enable = true;

  # virt-manager GUI (pulls in dconf so it can persist connection settings)
  programs.virt-manager.enable = true;
  programs.dconf.enable = true;
  environment.systemPackages = with pkgs; [
    quickemu
    qemu
    virtiofsd
    spice-gtk
    swtpm
    virtio-win # was: win-virtio
  ];
  # ---- quickemu (direct QEMU wrapper, independent of libvirt) ----

  # group membership — lets you manage VMs without sudo and open /dev/kvm
  users.users.teodor.extraGroups = [
    "libvirtd"
    "kvm"
  ];

  # ---- optional: nested virtualization (AMD) ----
  # boot.extraModprobeConfig = "options kvm_amd nested=1";
}
