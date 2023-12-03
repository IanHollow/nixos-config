{
  config,
  lib,
  ...
}:
with lib; {
  # define custom option for ssd
  options = {
    ssd = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };

  config = mkIf (config.ssd.enable) {
    services.fstrim.enable = true;
  };
}
