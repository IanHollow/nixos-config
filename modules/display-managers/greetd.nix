{
  pkgs,
  unstable,
  config,
  vars,
  lib,
  ...
}:
with lib; {
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
          # TODO: setup ReGreet or gtkgreet as greeters
          # Define greetd-tui
          greetd_tui_exec = "${pkgs.greetd.tuigreet}/bin/tuigreet";
          greetd_tui_args = strings.concatStringsSep " " [
            "--time"
            "--time-format '%I:%M %p | %a • %h | %F'"
            "--sessions /etc/greetd/wayland-sessions:/etc/greetd/xsessions"
          ];
          greetd_tui_command = "${greetd_tui_exec} ${greetd_tui_args}";
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

      # Configure keyring
      security.pam.services.greetd.enableGnomeKeyring = mkIf (config.keyring.enable) true;
    })
  ];
}
