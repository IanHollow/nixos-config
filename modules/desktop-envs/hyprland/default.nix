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
with lib; let
  nixos_config = config;
in {
  imports = [
    inputs.hyprland.nixosModules.default
    ./config
    ./display-manager.nix
    ./env.nix
    ./xdg.nix
  ];

  # define custom options for hyprland
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
      # TODO: move monitor options to a seperate module in the hardware modules
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
              Example: DP-1, HDMI-A-1, eDP-1.
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

  config = mkIf (nixos_config.hyprland.enable) {
    wlwm.enable = true; # Define Wayland Window Manager as enabled

    # install required packages for the Hyprland configuration
    environment.systemPackages = with pkgs; [
      grim # Grab Images
      slurp # Region Selector
      swappy # Snapshot Editor
      swayidle # Idle Daemon
      swaylock # Lock Screen
      wl-clipboard # Clipboard
      wlr-randr # Monitor Settings
      networkmanagerapplet
      blueman
      ranger
    ];

    # enable custom modules through options
    mako.enable = true; # Notifications
    rofi.enable = true; # Application Launcher & Other Menus

    home-manager.users.${vars.user} = {config, ...}: {
      # Import the Hyprland Nix module
      imports = [inputs.hyprland-nix.homeManagerModules.default];

      # TODO: fix issue with firefox pop windows becoming full screen

      # enable the hyprland configuration
      wayland.windowManager.hyprland = {
        # Enable Hyprland
        enable = true;
        package = inputs.hyprland.packages.${pkgs.system}.hyprland;
        xwayland.enable = true; # Enable XWayland
        reloadConfig = true;
        systemdIntegration = true;

        # Configure the Settings
        # Docs:
        # https://wiki.hyprland.org/Configuring/Variables/
        # TODO: follow github:hyprland-community/hyprland-nix/hm-module/configRenames.nix for new names for hyprland settings/config
        config = let
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
            "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";

            # Border color for inactive windows
            "col.inactive_border" = "rgba(595959aa)";

            # Hide cursor timeout (in seconds). Set to 0 for never
            cursor_inactive_timeout = 0;

            # Select Layout (options: dwindle, master)
            layout = "dwindle";

            # Screen tearing (default: false)
            allow_tearing = nixos_config.hyprland.allowTearing;
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
            vrr =
              if nixos_config.hyprland.monitors.primary.vrr
              then 1
              else 0;

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
          };

          # Set the monitor settings
          # TODO: Add laptop lid settings
          monitor = let
            name = nixos_config.hyprland.monitors.primary.name;
            height = nixos_config.hyprland.monitors.primary.resolution.height;
            width = nixos_config.hyprland.monitors.primary.resolution.width;
            refreshRate = nixos_config.hyprland.monitors.primary.refreshRate;
            colorDepth = nixos_config.hyprland.monitors.primary.colorDepth;
            # Calculate scale # TODO: Make this better later
            # scale = (trivial.min height width) / 1080.0;
            scale = 2; # This is a temporary fix for me while I work on a better calculation
            # TODO: their should be a scale override option as some scales have issues
          in
            with builtins; [
              # Primary Monitor
              # "${toString name}, ${toString width}x${toString height}@${toString refreshRate}, 0x0, ${toString scale}, bitdepth, ${toString colorDepth}"
              "${toString name}, disable" # this is temporary

              # Other Monitors
              # TODO: add better way to handle other monitors
              "HDMI-A-1, 1920x1080@60, ${toString width}x0, 1"
            ];

          # Set Keybindings
          bind = let
            # TODO: Add another way to launch rofi for nvidia offload
            nvidiaOffload =
              if (nixos_config.nvidia_gpu.enable && nixos_config.nvidia_gpu.prime_render_offload.enable)
              then "nvidia-offload"
              else "";
          in [
            # Main keybindings
            "${mainMod}, Q, exec, ${pkgs.kitty}/bin/kitty" # TODO: make this based on default terminal
            "${mainMod}, R, exec, pkill rofi || ${pkgs.rofi-wayland}/bin/rofi -show drun"
            "${mainMod} SHIFT, R, exec, pkill rofi || ${nvidiaOffload} ${pkgs.rofi-wayland}/bin/rofi -show drun"
            "${mainMod}, C, killactive,"
            "${mainMod}, M, exit"
            "${mainMod}, L, exec, ${pkgs.swaylock}/bin/swaylock"
            "ControlShiftAlt, Delete, exec, pkill wlogout || ${pkgs.wlogout}/bin/wlogout -p layer-shell"

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
            "${mainMod} SHIFT, 1, movetoworkspace, 1"
            "${mainMod} SHIFT, 2, movetoworkspace, 2"
            "${mainMod} SHIFT, 3, movetoworkspace, 3"
            "${mainMod} SHIFT, 4, movetoworkspace, 4"
            "${mainMod} SHIFT, 5, movetoworkspace, 5"
            "${mainMod} SHIFT, 6, movetoworkspace, 6"
            "${mainMod} SHIFT, 7, movetoworkspace, 7"
            "${mainMod} SHIFT, 8, movetoworkspace, 8"
            "${mainMod} SHIFT, 9, movetoworkspace, 9"
            "${mainMod} SHIFT, 0, movetoworkspace, 10"

            # Media Keys
            ",XF86AudioPlay, exec, ${playerctl} play-pause"
            ",XF86AudioPrev, exec, ${playerctl} previous"
            ",XF86AudioNext, exec, ${playerctl} next"
            ",XF86AudioMute, exec, ${wpctl} set-mute @DEFAULT_SINK@ toggle"
          ];

          binde = [
            # Audio Keys
            # TODO: add user option to set the max volume limit (current is 1 for 100%)
            ",XF86AudioRaiseVolume, exec, ${wpctl} set-volume -l 1 @DEFAULT_SINK@ 5%+"
            ",XF86AudioLowerVolume, exec, ${wpctl} set-volume @DEFAULT_SINK@ 5%-"

            # Brightness Keys
            # TODO: enable this based on user options
            ",XF86MonBrightnessUp, exec, ${pkgs.lib.getExe pkgs.brightnessctl} set 5%+"
            ",XF86MonBrightnessDown, exec, ${pkgs.lib.getExe pkgs.brightnessctl} set 5%-"
          ];

          bindm = [
            # Move/Resize windows
            "${mainMod}, mouse:272, movewindow"
            "${mainMod}, mouse:273, resizewindow"
          ];

          exec_once = [
            # Fcitx
            # TODO: make sure startup for fcitx is enabled based upon user options
            "fcitx5 -d --replace &"

            # Keyring
            # TODO: make this based off of the keyring user options
            "${pkgs.gnome.gnome-keyring}/bin/gnome-keyring-daemon --start --components=secrets &"

            # Polkit
            # TODO: make this startup for polkit based on user options
            "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1 &"

            # Dbus
            "${pkgs.dbus}/dbus-upadate-activation-environment --all &"

            # Cursor
            "hyprctl setcursor ${config.home.pointerCursor.name} ${builtins.toString config.home.pointerCursor.size}"
          ];

          windowrulev2 = [
            # Fcitx
            # TODO: make sure windowrulev2 for fcitx is enabled based upon user options
            "pseudo, class:^(fcitx)$"

            # XWayland Video Bridge
            # DOCS: https://wiki.hyprland.org/Useful-Utilities/Screen-Sharing/#xwayland
            # TODO: make sure windowrulev2 for XWayland Video Bridge is enabled based upon user options
            "opacity 0.0 override 0.0 override, class:^(xwaylandvideobridge)$"
            "noanim, class:^(xwaylandvideobridge)$"
            "nofocus, class:^(xwaylandvideobridge)$"
            "noinitialfocus, class:^(xwaylandvideobridge)$"
          ];
        };
      };
    };

    # Disable Sleep & Hibernation
    # TODO: make a modules for sleep and hibernation
    systemd.sleep.extraConfig = ''
      AllowSuspend=no
      AllowHibernation=no
      AllowSuspendThenHibernate=no
      AllowHybridSleep=no
    '';
  };
}
