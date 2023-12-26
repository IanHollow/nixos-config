{
  pkgs,
  config,
  lib,
  ...
}:
with lib; {
  # define custome option for keyring
  options = {
    keyring = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };

  config = mkIf (config.keyring.enable) {
    # Keyring service (uses gnome-keyring regardless of Desktop Environment)
    services.gnome.gnome-keyring.enable = true;

    # GUI for keyring
    programs.seahorse.enable = !config.plasma.enable; # Plasma has its own keyring GUI

    # TODO: the keyring seems to autologin on boot however this can be from two new changes made:
    #       1. starting the keyring in hyprland config file at login
    #       2. setting the secrets xdg desktop portal interface to gnome-keyring
    #
    #       Which one of these made the keyring autologin on boot.
    #       Add a message in this file on the findings to help others.
  };
}
