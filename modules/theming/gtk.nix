{
  vars,
  pkgs,
  config,
  ...
}: {
  home-manager.users.${vars.user} = {
    # gtk's theme settings, generate files:
    #   1. ~/.config/gtk-3.0/settings.ini
    #   2. ~/.config/gtk-4.0/settings.ini
    gtk = {
      enable = true;

      font = {
        name = "Noto Sans";
        package = pkgs.noto-fonts;
      };

      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
      };

      theme = {
        # TODO: change to new theme and test that it works
        # https://github.com/catppuccin/gtk
        name = "Catppuccin-Macchiato-Compact-Pink-dark";
        package = pkgs.catppuccin-gtk.override {
          # https://github.com/NixOS/nixpkgs/blob/nixos-23.05/pkgs/data/themes/catppuccin-gtk/default.nix
          accents = ["pink"];
          size = "compact";
          variant = "mocha";
        };
      };
    };
  };
}
