{
  vars,
  pkgs,
  ...
}: {
  home-manager.users.${vars.user} = {
    lib,
    config,
    ...
  }: {
    home.activation.removeExistingGTKConfig = lib.hm.dag.entryBefore ["checkLinkTargets"] ''
      rm -f "${config.xdg.configHome}/gtk-2.0/gtkrc"
      rm -f "${config.xdg.configHome}/gtk-3.0/settings.ini"
      rm -f "${config.xdg.configHome}/gtk-4.0/settings.ini"
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
        name = "Noto Sans 11";
        package = pkgs.noto-fonts;
      };

      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
      };

      theme = {
        package = pkgs.gruvbox-gtk-theme;

        # Set the name of the theme
        # make sure the name is correct otherwise gtk theme will not be applied
        # you can check theme name by running: ls /nix/store/*-${package}-*/share/themes
        # and look for theme based on your configuration
        # if the theme does not apply then you selected the wrong name
        name = "Gruvbox-Dark-BL";
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
