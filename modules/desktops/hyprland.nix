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
  inputs,
  ...
}:
with lib; {
  # import the hyprland module
  imports = [inputs.hyprland.nixosModules.default];

  # define custom option for hyprland
  options = {
    hyprland = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };

  config = mkIf (config.hyprland.enable) {
    wlwm.enable = true; # Define Wayland Window Manager as enabled

    # Start Hyprland from TTY1
    # TODO: check if this is needed still since greetd is used
    environment.loginShellInit = let
      exec = "exec dbus-launch Hyprland"; # Command to start Hyprland
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
      xdg-utils # XDG Utilities needed for xdg-open
    ];

    # enable custom options
    mako.enable = true; # Notifications
    rofi.enable = true; # Application Launcher & Other Menus

    # Start greetd on TTY7
    services.greetd = {
      enable = true;
      vt = 7; # TTY7
      settings.default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --time-format '%I:%M %p | %a • %h | %F' --cmd Hyprland";
      };
    };

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

    # Hyprland Desktop Manager
    programs.hyprland = {
      enable = true;
      package = inputs.hyprland.packages.${pkgs.system}.hyprland;
      portalPackage = unstable.xdg-desktop-portal-hyprland;
    };

    # Disable Sleep & Hibernation
    systemd.sleep.extraConfig = ''
      AllowSuspend=no
      AllowHibernation=no
      AllowSuspendThenHibernate=no
      AllowHybridSleep=no
    '';

    # Cache for the Hyprland Flake
    nix.settings = {
      substituters = ["https://hyprland.cachix.org"];
      trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
    };
  };
}
