{pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix

    ../../modules/profiles/cpu-amd.nix
    ../../modules/profiles/gpu-amd.nix
    ../../modules/profiles/gaming.nix
    ../../modules/profiles/performance.nix
    ../../modules/profiles/printer.nix
    ../../modules/profiles/vpn.nix
    ../../modules/profiles/rust.nix
    ../../modules/profiles/tailnet-host.nix
  ];

  networking.hostName = "teodor-gaming-nixos";

  main-user.enable = true;
  main-user.userName = "bane";

  # host-only tooling
  environment.systemPackages = [pkgs.templ]; # from inputs.templ overlay

  system.stateVersion = "24.05";



# { pkgs, inputs, ... }: {
  systemd.services.llama = {
    description = "llama-server for Anton";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    environment = {
      DIANE_LLM_HOST = "0.0.0.0";
      DIANE_GGUF = "/home/bane/.local/share/diane/Qwen2.5-14B-Instruct-Q4_K_M.gguf";
      DIANE_CTX = "8192";
    };
    serviceConfig = {
      ExecStart = "${inputs.diane.packages.${pkgs.stdenv.hostPlatform.system}.llama-server}/bin/diane-llama-server";
      User = "bane";
      SupplementaryGroups = [ "video" "render" ];
      Restart = "on-failure";
      RestartSec = 5;
    };
  };
# }

}
