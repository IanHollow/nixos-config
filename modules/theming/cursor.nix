{
  pkgs,
  vars,
  config,
  ...
}: let
  nixos_config = config;
in {
  home-manager.users.${vars.user} = {config, ...}: {
    home.pointerCursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 22;
      gtk.enable = true;
      x11.enable = nixos_config.x11wm.enable;
    };

    home.sessionVariables = {
      XCURSOR_THEME = config.home.pointerCursor.name;
      XCURSOR_SIZE = config.home.pointerCursor.size;
    };
  };
}
