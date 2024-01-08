{
  pkgs,
  unstable,
  vars,
  config,
  lib,
  ...
}:
with lib; {
  options.swaylock = {
    enable = mkOption {
      type = types.bool;
      default = config.swayidle.enable;
      description = "Enable swaylock";
    };
  };

  # Define config for swaylock
  config = mkIf (config.swaylock.enable) {
    # Configure PAM to allow swaylock to perform authentication
    security.pam.services.swaylock = {};

    # Install and configure swaylock
    # TODO: configure swaylock with more settings
    home-manager.users.${vars.user} = {
      programs.swaylock = {
        enable = true;
        package = pkgs.swaylock;
        settings = {
          color = "090B10AA";
        };
      };
    };
  };
}
