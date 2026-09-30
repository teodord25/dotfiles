{
  pkgs,
  inputs,
  ...
}: let
  diane = inputs.diane.packages.${pkgs.stdenv.hostPlatform.system}.default;
in {
  environment.systemPackages = [diane];
  environment.sessionVariables.DIANE_VAULT = "$HOME/vault";

  # Local capture page, used as Firefox's new tab (config/tridactyl/tridactylrc).
  # Loopback + DIANE_OPEN: no token; diane itself rejects non-loopback Host
  # headers and cross-site POSTs in open mode.
  systemd.user.services.diane-serve = {
    description = "diane capture page (Firefox new tab)";
    wantedBy = ["default.target"];
    environment = {
      DIANE_ADDR = "127.0.0.1:7777";
      DIANE_OPEN = "1";
      # never hang on a credential prompt; a failed pull/push is best-effort anyway
      GIT_TERMINAL_PROMPT = "0";
      GIT_SSH_COMMAND = "ssh -o BatchMode=yes";
    };
    serviceConfig = {
      ExecStart = "${diane}/bin/diane serve";
      Environment = [
        "DIANE_VAULT=%h/vault"
        "SSH_AUTH_SOCK=%t/ssh-agent" # programs.ssh.startAgent's socket
      ];
      Restart = "on-failure";
      RestartSec = 2;
    };
  };
}
