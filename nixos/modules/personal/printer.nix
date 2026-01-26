{ pkgs, ... }:
{
  services.printing.drivers = [ pkgs.hplip ];
}
