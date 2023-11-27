#
#  Hyprland Configuration
#  Enable with "hyprland.enable = true;"
#
{
  config,
  lib,
  system,
  pkgs,
  unstable,
  vars,
  host,
  inputs,
  ...
}:
with lib;
with host; {
  options = {
    hyprland = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };

  config = mkIf (config.hyprland.enable) {
    wlwm.enable = true; # Define that the Wayland Window Manager is used

    # Start Hyprland from TTY1
    environment.loginShellInit = let
      # Command to start Hyprland
      exec = "exec dbus-launch Hyprland";
    in ''
      if [ -z $DISPLAY ] && [ "$(tty)" = "/dev/tty1" ]; then
        ${exec}
      fi
    '';

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
          XDG_CURRENT_DESKTOP = "Hyprland";
          XDG_SESSION_DESKTOP = "Hyprland";

          # Qt Variables
          QT_AUTO_SCREEN_SCALE_FACTOR = "1";
          QT_QPA_PLATFORM = "wayland;xcb";
          QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";

          # Firefox
          MOZ_ENABLE_WAYLAND = "1";
          MOZ_WEBRENDER = "1";

          # ozone-based browsers & electron apps
          NIXOS_OZONE_WL = "1";
        }

        # Extra Variables
        extraNvidiaSessionVariables
      ];

    # install required packages for the Hyprland configuration
    environment.systemPackages = with pkgs; [
      grim # Grab Images
      slurp # Region Selector
      swappy # Snapshot Editor
      swayidle # Idle Daemon
      swaylock # Lock Screen
      wl-clipboard # Clipboard
      wlr-randr # Monitor Settings
      xdg-utils # XDG Utilities
      mako # Notifications
    ];

    # TODO: configure hyprland by enabling/disabling
    #       user made options for other packages or configurations

    # setup swaylock
    security.pam.services.swaylock = {
      text = ''
        auth include login
      '';
    };

    # Start greetd on TTY7
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --time-format '%I:%M %p | %a • %h | %F' --cmd Hyprland";
          user = vars.user;
        };
      };
      vt = 7;
    };

    # XDG Desktop Portal
    xdg.portal = {
      enable = true;
      extraPortals = [pkgs.xdg-desktop-portal-gtk];
    };

    programs = {
      hyprland = {
        # Window Manager
        enable = true;
        package = inputs.hyprland.packages.${pkgs.system}.hyprland;
        nvidiaPatches = config.nvidia_gpu.enable;
      };
    };

    systemd.sleep.extraConfig = ''
      AllowSuspend=no
      AllowHibernation=no
      AllowSuspendThenHibernate=no
      AllowHybridSleep=no
    ''; # Disable Sleep & Hibernation

    nix.settings = {
      substituters = ["https://hyprland.cachix.org"];
      trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
    }; # Cache

    home-manager.users.${vars.user} = {
      programs.swaylock.settings = {
        #image = "$HOME/.config/wall";
        color = "000000f0";
        font-size = "24";
        indicator-idle-visible = false;
        indicator-radius = 100;
        indicator-thickness = 20;
        inside-color = "00000000";
        inside-clear-color = "00000000";
        inside-ver-color = "00000000";
        inside-wrong-color = "00000000";
        key-hl-color = "79b360";
        line-color = "000000f0";
        line-clear-color = "000000f0";
        line-ver-color = "000000f0";
        line-wrong-color = "000000f0";
        ring-color = "ffffff50";
        ring-clear-color = "bbbbbb50";
        ring-ver-color = "bbbbbb50";
        ring-wrong-color = "b3606050";
        text-color = "ffffff";
        text-ver-color = "ffffff";
        text-wrong-color = "ffffff";
        show-failed-attempts = true;
      };
    };
  };
}
