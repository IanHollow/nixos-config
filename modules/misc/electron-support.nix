{
  pkgs,
  vars,
  config,
  lib,
  ...
}: let
  nixos_config = config;
in
  with lib; {
    # TODO: enable certain flags based on user options for electron-support

    home-manager.users."${vars.user}" = {config, ...}: {
      home.file."${config.xdg.configHome}/electron-flags.conf".text = let
        wayland_flags = ''
          --enable-features=UseOzonePlatform
          --ozone-platform=wayland
        '';
        fcitx_flags = ''
          --enable-wayland-ime
        '';
      in
        strings.concatStrings [
          wayland_flags
          fcitx_flags
        ];
    };
  }
