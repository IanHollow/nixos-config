{
  pkgs,
  unstable,
  vars,
  config,
  lib,
  ...
}:
with lib; {
  # TODO: create options for swaylock
  # TODO: configure swaylock with settings

  security.pam.services.swaylock = {};

  home-manager.users.${vars.user} = {
    programs.swaylock = {
      enable = true;
      settings = {
        color = "090B10AA";
      };
    };
  };
}
