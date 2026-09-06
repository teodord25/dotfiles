{ pkgs, inputs, ... }: {
  systemd.services.llama = {
    description = "llama-server for Anton";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    environment = {
      DIANE_LLM_HOST = "0.0.0.0";
      DIANE_GGUF = "/home/bane/.local/share/diane/Qwen2.5-14B-Instruct-Q4_K_M.gguf";
      DIANE_CTX = "32768";
    };
    serviceConfig = {
      ExecStart = "${inputs.diane.packages.${pkgs.stdenv.hostPlatform.system}.llama-server}/bin/diane-llama-server";
      User = "bane";
      SupplementaryGroups = [ "video" "render" ];
      Restart = "on-failure";
      RestartSec = 5;
    };
  };
}
