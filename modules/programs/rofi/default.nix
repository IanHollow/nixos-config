{
  pkgs,
  vars,
  config,
  lib,
  ...
}:
with lib; {
  # define custom option for rofi
  options = {
    rofi = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };

  config = mkIf (config.rofi.enable) {
    home-manager.users.${vars.user} = let
      nixos_config = config; # to prevent home-manager from overwriting the config
    in
      {
        config,
        lib,
        ...
      }: {
        # TODO: create a new rofi config most likely from config files
        programs.rofi = {
          enable = true;
          package =
            if nixos_config.wlwm.enable
            then pkgs.rofi-wayland
            else pkgs.rofi;
          theme = "gruvbox-dark-hard";
          font = "CaskaydiaCove Nerd Font 14";
          location = "center";
          extraConfig = {
            modi = "drun,run,window,ssh";
            show-icons = true;
            icon-theme = "Papirus-Dark";
          };
        };

        home.activation.removeExistingRofiConfig = lib.hm.dag.entryBefore ["checkLinkTargets"] ''
          rm -f "${config.xdg.configHome}/rofi/config.rasi"
        '';
      };
  };
}
