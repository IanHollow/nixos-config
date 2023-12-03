{
  pkgs,
  vars,
  lib,
  config,
  ...
}:
with lib; {
  # define custom option for mako
  options = {
    mako = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };

  config = mkIf (config.mako.enable) {
    # install mako
    environment.systemPackages = with pkgs; [
      mako
    ];

    # configure mako
    home-manager.users.${vars.user} = {
      lib,
      config,
      ...
    }: {
      # create mako config
      # TODO: create a new mako config and test it
      home.file."${config.xdg.configHome}/mako/config".source = ./mako.conf;

      # remove mako config files before creating new ones
      # this prevents home-manager from failing to create a new config
      home.activation.removeExistingMakoConfig = lib.hm.dag.entryBefore ["checkLinkTargets"] ''
        rm -f "${config.xdg.configHome}/mako/config"
      '';
    };
  };
}
