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
in {
  home-manager.users.${vars.user} = {config, ...}: {
    programs.wlogout = {
      enable = true;
      package = pkgs.wlogout;
      # style = ./style.css; # TODO: configure wlogout style.css correctly
      layout = [
        {
          label = "lock";
          action = "gtklock";
          text = "lock";
          keybind = "l";
        }
        {
          label = "hibernate";
          action = "systemctl hibernate";
          text = "save";
          keybind = "h";
        }
        {
          label = "logout";
          action = "loginctl terminate-user $USER";
          text = "logout";
          keybind = "e";
        }
        {
          label = "shutdown";
          action = "systemctl poweroff";
          text = "power_settings_new";
          keybind = "s";
        }
        {
          label = "suspend";
          action = "systemctl suspend";
          text = "bedtime";
          keybind = "u";
        }
        {
          label = "reboot";
          action = "systemctl reboot";
          text = "restart_alt";
          keybind = "r";
        }
      ];
    };

    # Write extra files to the config directory
    home.file."${config.xdg.configHome}/wlogout/noise.png".source = ./noise.png;
  };
}
