{ pkgs, inputs, ... }:
let
  diane = inputs.diane.packages.${pkgs.stdenv.hostPlatform.system};
  user = "bane";
  config-dir = "/home/${user}/.config/diane";

  server = name: envFile: {
    description = "${name} model server for Anton";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      ExecStart = "${diane.llama-server}/bin/diane-llama-server";
      EnvironmentFile = "-${envFile}";
      User = user;
      SupplementaryGroups = [ "video" "render" ];
      Restart = "on-failure";
      RestartSec = 5;
      TimeoutStartSec = "10min";
    };
  };
in
{
  systemd.services.llama = (server "fast" "${config-dir}/fast.env") // {
    wantedBy = [ "multi-user.target" ];
    conflicts = [ "llama-smart.service" ];
    environment.DIANE_LLM_HOST = "0.0.0.0";
  };

  systemd.services.llama-smart = (server "smart" "${config-dir}/smart.env") // {
    conflicts = [ "llama.service" ];
    environment.DIANE_LLM_HOST = "0.0.0.0";
  };
}
