{
  config,
  pkgs,
  ...
}: {
  boot.extraModprobeConfig = ''
    options kvm ignore_msrs=1
  '';

  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
    };
  };

  virtualisation.spiceUSBRedirection.enable = true;

  programs.virt-manager.enable = true;
  programs.dconf.enable = true;

  environment.systemPackages = with pkgs; [
    quickemu
    qemu
    virtiofsd
    spice-gtk
    swtpm
    virtio-win
  ];

  users.users.${config.main-user.userName}.extraGroups = [
    "libvirtd"
    "kvm"
  ];
}
