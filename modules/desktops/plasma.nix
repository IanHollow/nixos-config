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
    plasma = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };

  config = mkIf (config.plasma.enable) {
    wlwm.enable = true; # Define that the Wayland Window Manager is used

    # Login Manager
    services.xserver = {
      enable = true;
      xkb.layout = "us";
      displayManager.sddm = {
        enable = true;
        wayland.enable = true;
      };
    };

    # Plasma Desktop
    services.xserver.desktopManager.plasma5 = {
      enable = true;
      useQtScaling = true;
    };

    # set environment variables for the session
    environment.sessionVariables = let
      extraNvidiaSessionVariables =
        # TODO: change this if statement when I make better options
        # Check if NVIDIA is the only GPU or Main (kind of not full proof yet)
        if (config.nvidia_gpu.enable && !config.intel_gpu.integrated.enable)
        then {
          LIBVA_DRIVER_NAME = "nvidia";
          GBM_BACKEND = "nvidia-drm";
          __GLX_VENDOR_LIBRARY_NAME = "nvidia";
          WLR_NO_HARDWARE_CURSORS = "1";
        }
        else {};
    in
      # Merge the base variables with the extra variables
      mkMerge [
        # Base Variables
        {
          # XDG Specifications
          XDG_SESSION_TYPE = "wayland"; # Also needed for NVIDIA GPUs

          # Qt Variables
          QT_AUTO_SCREEN_SCALE_FACTOR = "1";
          QT_QPA_PLATFORM = "wayland;xcb";

          # Firefox
          MOZ_ENABLE_WAYLAND = "1";
          MOZ_WEBRENDER = "1";

          # ozone-based browsers & electron apps
          NIXOS_OZONE_WL = "1";
        }

        # Extra Variables
        extraNvidiaSessionVariables
      ];

    # Install additional packages
    environment.systemPackages = with pkgs; [
      xdg-utils
    ];

    # XDG Desktop Portal
    xdg = {
      portal = {
        enable = true;
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
