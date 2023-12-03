{
  pkgs,
  vars,
  config,
  ...
}: {
  home-manager.users.${vars.user} = {
    home.pointerCursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 22;
      gtk.enable = true;
      x11.enable = config.x11wm.enable;
    };
  };
}
