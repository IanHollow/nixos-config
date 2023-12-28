{
  pkgs,
  unstable,
  config,
  lib,
  inputs,
  vars,
  ...
}:
with lib; {
  # check if hyprland is enabled
  config = mkMerge [
    (mkIf (config.hyprland.enable) {
      # Confugure greetd
      greetd = {
        # Enable greetd
        enable = true;

        # Define Hyprland Session
        session = {
          # Define session name
          name = "Hyprland";

          # Define Wayland session
          wayland = true;

          # Define session command
          command = let
            hyprland_package = inputs.hyprland.packages.${pkgs.system}.hyprland;
            hyprland_exec = "${hyprland_package}/bin/Hyprland";
          in
            hyprland_exec;
        };

        # Enable autoLogin
        autoLogin = {
          enable = true;
          user = vars.user;
        };
      };
    })
  ];
}
