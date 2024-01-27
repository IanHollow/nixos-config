{
  pkgs,
  unstable,
  vars,
  lib,
  config,
  ...
}:
with lib; let
  nixos_config = config;
  hm = home-manager.users.${vars.users};
in {
  config = mkIf (nixos_config.hyprland.enable) {
    hm = {config, ...}: {
      programs.hyprland.settings = {
      };
    };
  };
}
