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

    # TODO: start the pam service for the keyring
    # NOTE: this hasn't been working & another solution is needed
    # greetd
    # security.pam.services.greetd.enableGnomeKeyring = true;
  };
}
