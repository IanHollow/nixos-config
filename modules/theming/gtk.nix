{
  vars,
  pkgs,
  unstable,
  ...
}: {
  home-manager.users.${vars.user} = {
    lib,
    config,
    ...
  }: {
    home.activation.removeExistingGTKConfig = lib.hm.dag.entryBefore ["checkLinkTargets"] ''
      rm -rf "${config.xdg.configHome}/gtk-2.0"
      rm -rf "${config.xdg.configHome}/gtk-3.0"
      rm -rf "${config.xdg.configHome}/gtk-4.0"
    '';

    dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";

    gtk = {
      enable = true;

      gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";

      gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };

      gtk4.extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };

      font = {
        name = "Noto Sans";
        package = pkgs.noto-fonts;
      };

      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
      };

      # TODO: change the theme and test it
      theme = {
        # Override the default theme for more customization
        # DOCS: https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/data/themes/catppuccin-gtk/default.nix
        package = unstable.catppuccin-gtk.override {
          accents = ["lavender"];
          size = "standard";
          tweaks = [];
          variant = "mocha";
        };

        # Set the name of the theme
        # make sure the name is correct otherwise gtk theme will not be applied
        # you can check theme name by running: ls /nix/store/*-${gtk_package_name}-*/share/themes
        # and look for theme based on your configuration
        # if the theme does not apply then you selected the wrong name
        name = "Catppuccin-Mocha-Standard-Lavender-Dark";
      };
    };
  };

  # enable dconf so that gtk and gnome apps work on none gnome desktops
  programs.dconf.enable = true;

  # For viewing gnome and gtk settings
  # environment.systemPackages = with pkgs; [
  #   gnome.gnome-tweaks
  #   gnome.dconf-editor
  # ];
}
