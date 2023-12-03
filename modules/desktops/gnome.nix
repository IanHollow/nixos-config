{
  pkgs,
  unstable,
  vars,
  config,
  lib,
  ...
}:
with lib; {
  options = {
    gnome = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };

  config = mkIf (config.gnome.enable) {
    wlwm.enable = true; # Define that the Wayland Window Manager is used

    # Login Manager
    services.xserver = {
      enable = true;
      xkb.layout = "us";
      displayManager.gdm = {
        enable = true;
        wayland = true;
      };
    };

    # GNOME Desktop
    services.xserver.desktopManager.gnome.enable = true;

    # Remove packages from the default GNOME desktop
    environment.gnome.excludePackages =
      (with pkgs; [
        gnome-photos
        gnome-tour
      ])
      ++ (with pkgs.gnome; [
        cheese # webcam tool
        gnome-music
        gnome-terminal
        gedit # text editor
        epiphany # web browser
        geary # email reader
        evince # document viewer
        gnome-characters
        totem # video player
        tali # poker game
        iagno # go game
        hitori # sudoku game
        atomix # puzzle game
      ]);

    # Install additional packages
    environment.systemPackages = with pkgs; [
      xdg-utils # for xdg-open
    ];

    # XDG Desktop Portal
    xdg.portal = {
      enable = true;

      extraPortals = [
        pkgs.xdg-desktop-portal-gtk # GTK Portal
      ];

      config.hyprland = {
        default = ["hyprland" "gtk"];
      };
    };

    # Disable Sleep & Hibernation
    systemd.sleep.extraConfig = ''
      AllowSuspend=no
      AllowHibernation=no
      AllowSuspendThenHibernate=no
      AllowHybridSleep=no
    '';
  };
}
