{
  pkgs,
  unstable,
  vars,
  config,
  lib,
  inputs,
  ...
}:
with lib; {
  options.swayidle = {
    enable = mkEnableOption "Enable swayidle";
  };

  config = mkIf (config.swayidle.enable) {
    assertions = [
      {
        # NOTE: this assertion may change in the future if more lock screen managers are added to this config
        assertion = config.swayidle.enable;
        message = "Swayidle must be enabled to use this module.";
      }
    ];

    home-manager.users."${vars.user}" = let
      # Hyrpland variables
      hyprland_enabled = config.hyprland.enable;
      hyprland_pkg = inputs.hyprland.packages.${pkgs.system}.hyprland;
      hyprctl_exec = "${hyprland_pkg}/bin/hyprctl";

      # Swaylock variables
      swaylock_exec = "${pkgs.swaylock}/bin/swaylock -fF";

      # Systemd variables
      systemctl_exec = "${pkgs.systemd}/bin/systemctl";
    in {
      services.swayidle = {
        enable = true;

        package = pkgs.swayidle;

        # TODO: create a way to prevent the screen of turning off when the user is watching a video or another task that requires the screen to be on
        # # Configure timeouts
        # timeouts = [
        #   # First timeout: Lock screen
        #   {
        #     timeout = 300;
        #     command = swaylock_exec;
        #   }

        #   # Second timeout: Suspend system
        #   {
        #     timeout = 600;
        #     command = "${systemctl_exec} suspend";
        #   }
        # ];

        # Configure events
        events = [
          # Before Sleep
          {
            event = "before-sleep";
            command = strings.concatStringsSep " && " [
              # Base commands
              "${swaylock_exec}"
              # Hyprland specific
              (
                optionals hyprland_enabled
                "${hyprctl_exec} dispatch dpms on"
              )
            ];
          }

          # After Resume
          {
            event = "after-resume";
            command = strings.concatStringsSep " && " [
              # Hyprland specific
              (
                optionals hyprland_enabled
                "${hyprctl_exec} dispatch dpms on"
              )
            ];
          }
        ];
      };
    };
  };
}
