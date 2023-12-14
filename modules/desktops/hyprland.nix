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
  # import the hyprland module fir nixos
  imports = [inputs.hyprland.nixosModules.default];

  # define custom option for hyprland
  options = {
    hyprland = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
      allowTearing = mkOption {
        type = types.bool;
        default = false;
      };
      monitors = {
        primary = {
          enable = mkOption {
            type = types.bool;
            default = false;
          };
          name = mkOption {
            type = types.str;
            default = "DP-1";
            description = ''
              The name of the primary monitor.
              Example: DP-1, HDMI-1, eDP-1.
              Use "hyprctl monitors all" to list all monitors.
            '';
          };
          resolution = {
            height = mkOption {
              type = types.int;
              default = 1080;
            };
            width = mkOption {
              type = types.int;
              default = 1920;
            };
          };
          refreshRate = mkOption {
            type = types.int;
            default = 60;
          };
          colorDepth = mkOption {
            type = types.int;
            default = 8;
          };
          vrr = mkOption {
            type = types.bool;
            default = false;
          };
        };
      };
    };
  };

  config = mkIf (config.hyprland.enable) {
    wlwm.enable = true; # Define Wayland Window Manager as enabled

    # set environment variables for the session
    environment.sessionVariables = let
      nvidia_vars =
        # TODO: change this if statement when I make better options
        # Check if NVIDIA is the only GPU or Main (kind of not full proof yet)
        if (config.nvidia_gpu.enable && !config.intel_gpu.integrated.enable)
        then let
          vrr_vars =
            if (config.hyprland.monitors.primary.vrr)
            then {
              __GL_GSYNC_ALLOWED = "1";
              __GL_VRR_ALLOWED = "1";
            }
            else {
              __GL_GSYNC_ALLOWED = "0";
              __GL_VRR_ALLOWED = "0";
            };
        in
          mkMerge [
            # NVIDIA Variables
            {
              LIBVA_DRIVER_NAME = "nvidia";
              GBM_BACKEND = "nvidia-drm";
              __GLX_VENDOR_LIBRARY_NAME = "nvidia";
              WLR_NO_HARDWARE_CURSORS = "1";
            }

            # VRR Variables for NVIDIA
            vrr_vars
          ]
        else {};

      # Check if the user wants to disbale allow_tearing
      tearing_vars =
        if (config.hyprland.allowTearing)
        then {
          WLR_DRM_NO_ATOMIC = "1";
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

          # Java
          _JAVA_AWT_WM_NONREPARENTING = "1";

          # ozone-based browsers & electron apps
          NIXOS_OZONE_WL = "1";
        }

        # Extra Variables
        nvidia_vars
        tearing_vars
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
      networkmanagerapplet
      blueman
      ranger
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
        user = vars.user;
      };
    };

    # XDG Desktop Portal
    xdg.portal = {
      enable = true;

      extraPortals = [
        unstable.xdg-desktop-portal-hyprland # Hyprland Portal
        pkgs.xdg-desktop-portal-gtk # GTK Portal
      ];

      config.hyprland = {
        default = ["hyprland" "gtk"];
      };
    };

    # TODO: create hyprland config in non home-manager config to see if flickering is fixed
    # Hyprland Desktop Manager
    # programs.hyprland = {
    #   enable = true;
    #   package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    #   portalPackage = unstable.xdg-desktop-portal-hyprland;
    # };

    home-manager.users.${vars.user} = {
      # NOTE: importing the home-manager modules for hyprland flake prevents using settings field

      # enable the hyprland configuration
      wayland.windowManager.hyprland = {
        # Enable Hyprland
        enable = true;
        package = inputs.hyprland.packages.${pkgs.system}.hyprland;
        xwayland.enable = true; # Enable XWayland

        # Configure the Settings
        # Docs:
        # https://wiki.hyprland.org/Configuring/Variables/
        settings = let
          playerctl = "${pkgs.playerctl}/bin/playerctl";
          wpctl = "${pkgs.wireplumber}/bin/wpctl";
          mainMod = "SUPER";
        in {
          general = let
            gap_size = 5;
          in {
            # Mouse sensitivity
            # NOTE: Use input:sensitivity instead of general:sensitivity to avoid
            #       bugs especially with Wine/Proton apps
            # sensitivity = 0; # 0 means no modification

            # Size of borders around windows
            border_size = 2;

            # Disable borders on floating windows
            no_border_on_floating = false;

            # Gaps between windows
            gaps_in = gap_size / 2;

            # Gaps between windows and monitor edges
            gaps_out = gap_size;

            # Border color for active windows
            "col.active_border" = "rgba(014F86FF)";

            # Border color for inactive windows
            "col.inactive_border" = "rgba(454559FF)";

            # Hide cursor timeout (in seconds). Set to 0 for never
            cursor_inactive_timeout = 0;

            # Select Layout (options: dwindle, master)
            layout = "dwindle";

            # Screen tearing (default: false)
            allow_tearing = config.hyprland.allowTearing;
          };

          decoration = {
            # Amount of rounding on window corners
            rounding = 6;

            # Drop shadow on windows
            drop_shadow = true;

            # Shadow range (in pixels)
            shadow_range = 10;

            # Shadow render power ((1 - 4) more power = faster falloff)
            shadow_render_power = 2;

            # Shadow color (in hex)
            "col.shadow" = "rgba(00000044)";

            # Shadow offset (vector in pixels)
            shadow_offset = "0 0";

            # Blur settings
            blur = {
              # Enable blur
              enabled = true;

              # Blur size (distance)
              size = 4;

              # Amount of blur passes
              passes = 4;

              # Ignore opacity when blurring
              ignore_opacity = true;

              # Enable new blur optimizations
              new_optimizations = true;

              # Floating windows will ignore tiled windows in their blur
              # NOTE: Will reduce overhead of floating blur significantly
              #       but the new_optimizations option must be enabled
              xray = true;

              # Amount of noise to apply (0 - 1)
              noise = 0.03;

              # Amount of contrast to apply (0 - 2)
              contrast = 1.0;
            };
          };

          animations = {
            # Enable animations
            enabled = true;

            # Animation on first launch
            first_launch_animation = true;

            # Animation curves
            bezier = [
              "mycurve,.32,.97,.53,.98"
              "easeInOut,.5,0,.5,1"
              "overshot,.32,.97,.37,1.16"
              "easeInOut,.5,0,.5,1"
            ];

            # Animations
            # TODO: Review current animations and add more animations
            animation = [
              "windowsMove,1,4,overshot"
              "windowsIn,1,3,mycurve"
              "windowsOut,1,10,mycurve,slide"
              "fadeIn,1,3,mycurve"
              "fadeOut,1,3,mycurve"
              "border,1,5,mycurve"
            ];
          };

          input = {
            # Mouse sensitivity
            sensitivity = 0; # 0 means no modification

            # Mouse acceleration
            accel_profile = "flat";

            # Set keyboard layout
            kb_layout = "us";

            # Specify how cursor movement affects window focus
            # 0 - Cursor movement will not change focus.
            # 1 - Cursor movement will always change focus to the window under the cursor.
            # 2 - Cursor focus will be detached from keyboard focus. Clicking on a window will move keyboard focus to that window.
            # 3 - Cursor focus will be completely separate from keyboard focus. Clicking on a window will not change keyboard focus.
            follow_mouse = 1;

            touchpad = {
              # Disable touchpad while typing
              disable_while_typing = true;

              # Natural scrolling
              natural_scroll = true;

              # Tap to click
              tap-to-click = true;

              # Tap to drag
              tap-and-drag = true;

              # Drag lock
              # lifitng the finder off for a short time will not end the drag
              drag_lock = true;
            };
          };

          # gestures = {};

          # group = {};

          misc = {
            # Varible Frame Rate
            vfr = true;

            # Variable Refresh Rate
            # 0 - off, 1 - on, 2 - fullscreen only
            # TODO: Only enable this if the monitor supports it
            vrr = 1;

            # Animate manual window resizes
            animate_manual_resizes = true;

            # Force Default Wallpaper
            force_default_wallpaper = 1;

            # TODO: Add swallow
          };

          binds = {
            # On attempt to switch to the currently focused workspace will instead switch to the previous workspace
            workspace_back_and_forth = false;
          };

          xwayland = {
            # uses the nearest neigbor filtering for xwayland apps, making them pixelated rather than blurry
            use_nearest_neighbor = true;

            # forces a scale of 1 on xwayland windows on scaled displays.
            force_zero_scaling = true;
          };

          # Configure the dwindle layout
          dwindle = {
            # Pseudotiled windows retain their floating size when tiled
            pseudotile = false;

            # Force split direction
            # 0 - Split follows mouse
            # 1 - Split is left or top
            # 2 - Split is right or bottom
            force_split = 2;

            # the split (side/top) will not change regardless of what happens to the container
            preserve_split = true;

            # Default split ratio on window open. 1 means even 50/50 split. (0.1 - 1.9)
            default_split_ratio = 1.2;
          };

          # Set the monitor settings
          monitor = let
            name = config.hyprland.monitors.primary.name;
            height = config.hyprland.monitors.primary.resolution.height;
            width = config.hyprland.monitors.primary.resolution.width;
            refreshRate = config.hyprland.monitors.primary.refreshRate;
            colorDepth = config.hyprland.monitors.primary.colorDepth;
            # Calculate scale # TODO: Make this better later
            # scale = (trivial.min height width) / 1080.0;
            scale = 1.35; # This is a temporary fix for me while I work on a better calculation
          in
            with builtins; [
              "${toString name}, ${toString height}x${toString width}@${toString refreshRate}, 0x0, ${toString scale}, bitdepth, ${toString colorDepth}"
            ];

          # Set Keybindings
          bind = [
            # Main keybindings
            "${mainMod}, Q, exec, ${pkgs.kitty}/bin/kitty" # TODO: make this based on default terminal
            "${mainMod}, R, exec, ${pkgs.rofi-wayland}/bin/rofi -show drun"
            "${mainMod}, C, killactive,"
            "${mainMod}, M, exit"

            # Move focus with mainMod + arrow keys
            "${mainMod}, left, movefocus, l"
            "${mainMod}, right, movefocus, r"
            "${mainMod}, up, movefocus, u"
            "${mainMod}, down, movefocus, d"

            # Switch active workspace
            "${mainMod}, 1, workspace, 1"
            "${mainMod}, 2, workspace, 2"
            "${mainMod}, 3, workspace, 3"
            "${mainMod}, 4, workspace, 4"
            "${mainMod}, 5, workspace, 5"
            "${mainMod}, 6, workspace, 6"
            "${mainMod}, 7, workspace, 7"
            "${mainMod}, 8, workspace, 8"
            "${mainMod}, 9, workspace, 9"
            "${mainMod}, 0, workspace, 10"

            # Move active window to a workspace
            "${mainMod}_SHIFT, 1, movetoworkspace, 1"
            "${mainMod}_SHIFT, 2, movetoworkspace, 2"
            "${mainMod}_SHIFT, 3, movetoworkspace, 3"
            "${mainMod}_SHIFT, 4, movetoworkspace, 4"
            "${mainMod}_SHIFT, 5, movetoworkspace, 5"
            "${mainMod}_SHIFT, 6, movetoworkspace, 6"
            "${mainMod}_SHIFT, 7, movetoworkspace, 7"
            "${mainMod}_SHIFT, 8, movetoworkspace, 8"
            "${mainMod}_SHIFT, 9, movetoworkspace, 9"
            "${mainMod}_SHIFT, 0, movetoworkspace, 10"

            # Media Keys
            ",XF86AudioPlay, exec, ${playerctl} play-pause"
            ",XF86AudioPrev, exec, ${playerctl} previous"
            ",XF86AudioNext, exec, ${playerctl} next"
            ",XF86AudioMute, exec, ${wpctl} set-mute @DEFAULT_SINK@ toggle"
          ];

          binde = [
            # Audio Keys
            ",XF86AudioRaiseVolume, exec, ${wpctl} set-volume -l 1 @DEFAULT_SINK@ 5%+"
            ",XF86AudioLowerVolume, exec, ${wpctl} set-volume @DEFAULT_SINK@ 5%-"

            # Brightness Keys
            ",XF86MonBrightnessUp, exec, ${pkgs.lib.getExe pkgs.brightnessctl} set 5%+"
            ",XF86MonBrightnessDown, exec, ${pkgs.lib.getExe pkgs.brightnessctl} set 5%-"
          ];

          bindm = [
            # Move/Resize windows
            "${mainMod}, mouse:272, movewindow"
            "${mainMod}, mouse:273, resizewindow"
          ];

          exec-once = [
            "fcitx5 -d --replace"
          ];

          windowrule = [
            "pseudo, class:^(fcitx)$"
          ];
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

    # Cache for the Hyprland Flake
    nix.settings = {
      substituters = ["https://hyprland.cachix.org"];
      trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
    };
  };
}
