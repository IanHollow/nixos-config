{
  pkgs,
  unstable,
  config,
  vars,
  lib,
  ...
}:
with lib; let
  home_config = config.home-manager.users.${vars.user};
in {
  # Define options for the greetd module
  options.greetd = {
    # Enable the greetd module
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable the greetd module";
    };

    # Define the session to use
    session = {
      # Define the session name
      name = mkOption {
        type = types.str;
        default = "greetd-session";
        description = "The name of the session";
      };

      # Define the session command
      command = mkOption {
        type = types.str;
        default = null;
        description = ''
          The desktop environment to use as a command.
          This should ideally be a path to to the desktop environment's binary
        '';
      };

      # Wayland session
      wayland = mkOption {
        type = types.bool;
        default = false;
        description = "Enable the wayland session";
      };

      # Xorg session
      xorg = mkOption {
        type = types.bool;
        default = false;
        description = "Enable the xorg session";
      };
    };

    # Define the auto login settings
    # TODO: move this somewhere else or make generic auto login options as this should be defined in host profile somewhere
    autoLogin = {
      # Enable auto login
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable auto login";
      };

      # Define the user to auto login as
      user = mkOption {
        type = types.str;
        default = null;
        description = "The user to auto login as";
      };
    };
  };

  config = mkMerge [
    # Check that the options are set correctly for the greetd module
    # TODO: put this inside of the greetd module
    {
      assertions = [
        {
          assertion = (config.greetd.enable && config.greetd.session.command != null) || !config.greetd.enable;
          message = "greetd: session.command must be set when greetd is enabled";
        }
        {
          assertion = (config.greetd.autoLogin.enable && config.greetd.autoLogin.user != null) || !config.greetd.autoLogin.enable;
          message = "greetd: autoLogin.user must be set when autologin is enabled";
        }
        {
          assertion = (config.greetd.session.wayland || config.greetd.session.xorg) || !config.greetd.enable;
          message = "greetd: session.wayland or session.xorg must be enabled when greetd is enabled";
        }
        {
          assertion = (config.greetd.session.wayland && !config.greetd.session.xorg) || (!config.greetd.session.wayland && config.greetd.session.xorg) || !config.greetd.enable;
          message = "greetd: session.wayland and session.xorg cannot both be enabled when greetd is enabled";
        }
      ];
    }

    # Configure the greetd module
    (mkIf (config.greetd.enable) {
      # Define the greetd service
      services.greetd = {
        # Enable the greetd service
        enable = true;

        # Set the TTY to use (common for display managers to use TTY7)
        vt = 7; #TTY7

        # Configure the greetd settings
        settings = let
          # Define greetd-tui
          greetd_tui_exec = "${pkgs.greetd.tuigreet}/bin/tuigreet";
          greetd_tui_args = strings.concatStringsSep " " [
            "--time"
            "--time-format '%I:%M %p | %a • %h | %F'"
            "--sessions /etc/greetd/wayland-sessions:/etc/greetd/xsessions"
          ];
          greetd_tui_command = "${greetd_tui_exec} ${greetd_tui_args}";

          # Define ReGreet
          regreet_exec = "${pkgs.greetd.regreet}/bin/regreet";
          cage_exec = "${pkgs.cage}/bin/cage";
          cage_args = strings.concatStringsSep " " [
            "-s"
            "--"
          ];
          regreet_command = "${cage_exec} ${cage_args} ${regreet_exec}";
        in {
          # Set the default session
          default_session = {
            command = greetd_tui_command;
            user = "greeter";
          };

          # Set the initial session if auto login is enabled
          initial_session = mkIf (config.greetd.autoLogin.enable) {
            command = config.greetd.session.command;
            user = config.greetd.autoLogin.user;
          };
        };
      };

      # Store sessions in in /etc for the greetd service
      environment.etc = let
        # Determine path for the sessions
        sessions =
          if (config.greetd.session.wayland)
          then "wayland-sessions"
          else "xsessions";
      in {
        "/greetd/${sessions}/${config.greetd.session.name}.desktop" = {
          text = ''
            [Desktop Entry]
            Name=${config.greetd.session.name}
            Exec=${config.greetd.session.command}
            Type=Application
          '';
          mode = "0755"; # Set permissions to rwxr-xr-x
          user = "root"; # Set owner to root
          group = "root"; # Set group to root
        };
      };

      # Configure ReGreet greeter
      # programs.regreet = {
      #   enable = true;
      #   package = pkgs.greetd.regreet;
      #   settings = {
      #     # background = {
      #     #   path = "";
      #     #   # Available values: "Fill", "Contain", "Cover", "ScaleDown"
      #     #   fit = "";
      #     # };
      #     # env = {};
      #     gtk = {
      #       application_prefer_dark_theme = true;
      #       cursor_theme_name = home_config.home.pointerCursor.name;
      #       font_name = home_config.gtk.font.name;
      #       icon_theme_name = home_config.gtk.iconTheme.name;
      #       theme_name = home_config.gtk.theme.name;
      #     };
      #     commands = {
      #       # The command used to reboot the system
      #       reboot = ["systemctl" "reboot"];

      #       # The command used to shut down the system
      #       poweroff = ["systemctl" "poweroff"];
      #     };
      #   };
      # };

      # Set environment variables for the ReGreet greeter
      # environment.variables = {
      #   SESSION_DIRS = "/etc/greetd/wayland-sessions:/etc/greetd/xsessions";
      # };

      # Configure keyring
      security.pam.services.greetd.enableGnomeKeyring = mkIf (config.keyring.enable) true;
    })
  ];
}
