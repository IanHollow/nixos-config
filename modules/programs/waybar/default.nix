{
  pkgs,
  unstable,
  config,
  lib,
  vars,
  inputs,
  ...
}:
with lib; let
  nixos_config = config;
in {
  # Define options for waybar
  options.waybar = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable waybar";
    };
  };

  config = mkIf (nixos_config.waybar.enable) {
    home-manager.users.${vars.user} = {config, ...}: {
      programs.waybar = {
        # Enable waybar
        enable = true;

        # Set the package
        package = pkgs.waybar;

        # Set the style
        style = ./style.css;

        # ''
        #   * {
        #     border: none;
        #     border-radius: 0px;
        #     font-family: JetBrainsMono Nerd Font;
        #     font-size: 17px;
        #   }
        # '';

        # Configure Settings
        settings = let
          # Hyrpland variables
          hyprland_enabled = nixos_config.hyprland.enable;
          hyprland_pkg = inputs.hyprland.packages.${pkgs.system}.hyprland;
          hyprctl_exec = "${hyprland_pkg}/bin/hyprctl";
        in {
          mainBar = {
            layer = "top"; # Display waybar windows on top
            position = "top"; # Place bar at the top of the screen
            # height = 30;
            exclusive = true;
            passthrough = false;
            gtk-layer-shell = true;

            # Left side
            modules-left = [
              "custom/padd"
              "custom/l_end"
              (optionals hyprland_enabled "hyprland/workspaces")
              "custom/r_end"
              "custom/padd"
            ];

            # Center
            modules-center = [
              "custom/padd"
              "custom/l_end"
              "clock"
              "custom/spotify"
              "custom/r_end"
              "custom/padd"
            ];

            # Right side
            modules-right = [
              "custom/padd"
              "custom/l_end"
              "tray"
              "custom/r_end"
              "custom/l_end"
              (optionals nixos_config.laptop.enable "battery")
              "network"
              "pulseaudio"
              "pulseaudio#microphone"
              "custom/r_end"
              "custom/padd"
            ];

            # Define modules
            "hyprland/workspaces" = {
              "format" = "{icon}";
              "format-icons" = {
                "1" = "1";
                "2" = "2";
                "3" = "3";
                "4" = "4";
                "5" = "5";
                "6" = "6";
                "7" = "7";
                "8" = "8";
                "9" = "9";
                "10" = "10";
              };
              "on-click" = "activate";
              "sort-by-number" = true;
              "all-outputs" = true;
              "active-only" = false;
              "persistent-workspaces" = {};
              # Scroll to next workspace
              "on-scroll-up" = "${hyprctl_exec} dispatch workspace e+1";
              "on-scroll-down" = "${hyprctl_exec} dispatch workspace e-1";
            };

            "tray" = {
              "icon-size" = "\${i_size}";
              "spacing" = 5;
            };

            "clock" = {
              "format" = "{:%I:%M %p}";
              "format-alt" = "{:%R 󰃭 %d·%m·%y}";
              "tooltip-format" = "<tt>{calendar}</tt>";
              "calendar" = {
                "mode" = "month";
                "mode-mon-col" = 3;
                "on-scroll" = 1;
                "on-click-right" = "mode";
                "format" = {
                  "months" = "<span color='#ffead3'><b>{}</b></span>";
                  "weekdays" = "<span color='#ffcc66'><b>{}</b></span>";
                  "today" = "<span color='#ff6699'><b>{}</b></span>";
                };
              };
            };

            "network" = {
              "format-wifi" = "󰤨 {essid}";
              "format-ethernet" = "󱘖 Wired";
              "tooltip-format" = "󱘖 {ipaddr}  {bandwidthUpBytes}  {bandwidthDownBytes}";
              "format-linked" = "󱘖 {ifname} (No IP)";
              "format-disconnected" = " Disconnected";
              "format-alt" = "󰤨 {signalStrength}%";
              "interval" = 5;
            };

            "battery" = {
              "bat" = "BAT0";
              "adapter" = "ADP0";
              "interval" = 60;
              "states" = {
                "warning" = 30;
                "critical" = 15;
              };
              "max-length" = 20;
              "format" = "{icon} {capacity}%";
              "format-warning" = "{icon} {capacity}%";
              "format-critical" = "{icon} {capacity}%";
              "format-charging" = "<span font-family='Font Awesome 6 Free'></span> {capacity}%";
              "format-plugged" = "  {capacity}%";
              "format-alt" = "{icon} {time}";
              "format-full" = "  {capacity}%";
              "format-icons" = [" " " " " " " " " "];
            };

            "pulseaudio" = {
              "format" = "{icon} {volume}";
              "format-muted" = "󰝟";
              "on-click" = "pavucontrol -t 3";
              #"on-click-middle" = "~/.config/hypr/scripts/volumecontrol.sh -o m";
              #"on-scroll-up" = "~/.config/hypr/scripts/volumecontrol.sh -o i";
              #"on-scroll-down" = "~/.config/hypr/scripts/volumecontrol.sh -o d";
              "tooltip-format" = "{icon} {desc} // {volume}%";
              "scroll-step" = 5;
              "format-icons" = {
                "headphone" = "";
                "hands-free" = "";
                "headset" = "";
                "phone" = "";
                "portable" = "";
                "car" = "";
                "default" = ["" "" ""];
              };
            };

            "pulseaudio#microphone" = {
              "format" = "{format_source}";
              "format-source" = "";
              "format-source-muted" = "";
              "on-click" = "pavucontrol -t 4";
              #"on-click-middle" = "~/.config/hypr/scripts/volumecontrol.sh -i m";
              #"on-scroll-up" = "~/.config/hypr/scripts/volumecontrol.sh -i i";
              #"on-scroll-down" = "~/.config/hypr/scripts/volumecontrol.sh -i d";
              "tooltip-format" = "{format_source} {source_desc} // {source_volume}%";
              "scroll-step" = 5;
            };

            "custom/spotify" = let
              # TODO: modify this to use something else https://discourse.nixos.org/t/how-to-have-gst-and-gtk-in-python/5241/2
              python_env = "nix-shell -p gobject-introspection -p playerctl -p 'python3.withPackages (p: with p; [pygobject3 gst-python])' --run";
            in {
              "format" = " {}";
              "return-type" = "json";
              "max-length" = 40;
              "escape" = true;
              "tooltip" = true;
              "exec" = "${python_env} 'python3 ${config.xdg.configHome}/waybar/scripts/mediaplayer.py --player spotify 2> /dev/null'"; # Only display music from spotify
              "on-click" = "playerctl previous --player spotify";
              "on-click-middle" = "playerctl play-pause --player spotify";
              "on-click-right" = "playerctl next --player spotify";
            };

            # // modules for padding //

            "custom/l_end" = {
              "format" = " ";
              "interval" = "once";
              "tooltip" = false;
            };

            "custom/r_end" = {
              "format" = " ";
              "interval" = "once";
              "tooltip" = false;
            };

            "custom/sl_end" = {
              "format" = " ";
              "interval" = "once";
              "tooltip" = false;
            };

            "custom/sr_end" = {
              "format" = " ";
              "interval" = "once";
              "tooltip" = false;
            };

            "custom/rl_end" = {
              "format" = " ";
              "interval" = "once";
              "tooltip" = false;
            };

            "custom/rr_end" = {
              "format" = " ";
              "interval" = "once";
              "tooltip" = false;
            };

            "custom/padd" = {
              "format" = "  ";
              "interval" = "once";
              "tooltip" = false;
            };
          };
        };
      };

      # Write additional files to Waybar config
      home.file."${config.xdg.configHome}/waybar/scripts/mediaplayer.py".source = "${inputs.waybar}/resources/custom_modules/mediaplayer.py";
      home.file."${config.xdg.configHome}/waybar/Catppuccin-Mocha.css".source = ./Catppuccin-Mocha.css;
    };

    # Temporary fix for waybar
    # TODO: move these packages to correct config files
    environment.systemPackages = with pkgs; [
      playerctl
      pavucontrol
    ];
  };
}
