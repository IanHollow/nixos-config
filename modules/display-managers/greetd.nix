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
    desktopSession = mkOption {
      type = types.str;
      default = null;
      description = "The desktop environment to use";
    };

    # Option for auto login
    autoLogin = {
      # Enable auto login
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable auto login";
      };

      # Define the user to auto login
      user = mkOption {
        type = types.str;
        default = null;
        description = "The user to auto login";
      };
    };
  };

  # Check that the options are set correctly for the greetd module
  config.assertions = [
    {
      assertion = (config.greetd.enable && config.greetd.desktopSession == null) || !config.greetd.enable;
      message = "greetd: desktopSession must be set when greetd is enabled";
    }
    {
      assertion = (config.greetd.autoLogin.enable && config.greetd.autoLogin.user == null) || !config.greetd.autoLogin.enable;
      message = "greetd: autoLogin.user must be set when autoLogin is enabled";
    }
  ];

  # TODO: finish the greetd module
}
