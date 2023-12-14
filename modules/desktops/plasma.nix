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
    # TODO: fix virtual keyboard layout starting in Albanian
    # TODO: set wayland as default session
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

    # Remove pacakges from the default Plasma desktop
    environment.plasma5.excludePackages = with pkgs.libsForQt5; [
      elisa
      gwenview
      okular
      oxygen
      khelpcenter
      konsole
      plasma-browser-integration
      print-manager
    ];

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

          # ozone-based browsers & electron apps
          NIXOS_OZONE_WL = "1";
        }

        # Extra Variables
        extraNvidiaSessionVariables
      ];

    # Install additional packages
    environment.systemPackages = with pkgs; [
      xdg-utils # needed for xdg-open
    ];

    # XDG Desktop Portal
    xdg.portal = {
      enable = true;
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
