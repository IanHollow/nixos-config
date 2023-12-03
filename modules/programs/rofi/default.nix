{
  pkgs,
  vars,
  config,
  ...
}: {
  home-manager.users."${vars.user}" = let
    nix_config = config;
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
          if nix_config.wlwm.enable
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
}
