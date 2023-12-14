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
  };
}
