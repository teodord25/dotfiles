{ pkgs, inputs, ... }: {
  environment.systemPackages = [
    inputs.diane.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
  environment.sessionVariables.DIANE_VAULT = "$HOME/vault";
}
