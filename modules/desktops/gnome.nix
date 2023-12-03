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
      xdg-utils
      xdg-desktop-portal-gtk
    ];

    # XDG Desktop Portal
    xdg = {
      portal = {
        enable = true;
        config = {
          gnome = {
            default = [
              "gnome"
              "gtk"
            ];
            "org.freedesktop.impl.portal.Secret" = [
              "gnome-keyring"
            ];
          };
        };
      };
      # manage $XDG_CONFIG_HOME/mimeapps.list
      # xdg search all desktop entries from $XDG_DATA_DIRS, check it by command:
      #  echo $XDG_DATA_DIRS
      # the system-level desktop entries can be list by command:
      #   ls -l /run/current-system/sw/share/applications/
      # the user-level desktop entries can be list by command(user):
      #  ls /etc/profiles/per-user/${user}/share/applications/
      mime = {
        enable = true;
        defaultApplications = let
          browser = ["firefox.desktop"];
        in {
          "application/json" = browser;
          "application/pdf" = browser; # TODO: pdf viewer

          "text/html" = browser;
          "text/xml" = browser;
          "application/xml" = browser;
          "application/xhtml+xml" = browser;
          "application/xhtml_xml" = browser;
          "application/rdf+xml" = browser;
          "application/rss+xml" = browser;
          "application/x-extension-htm" = browser;
          "application/x-extension-html" = browser;
          "application/x-extension-shtml" = browser;
          "application/x-extension-xht" = browser;
          "application/x-extension-xhtml" = browser;

          "x-scheme-handler/about" = browser;
          "x-scheme-handler/ftp" = browser;
          "x-scheme-handler/http" = browser;
          "x-scheme-handler/https" = browser;
          "x-scheme-handler/unknown" = browser;

          "x-scheme-handler/discord" = ["discord.desktop"];
          "x-scheme-handler/tg" = ["telegramdesktop.desktop"];

          "audio/*" = ["mpv.desktop"];
          "video/*" = ["mpv.dekstop"];
        };
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
