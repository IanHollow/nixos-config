{
  pkgs,
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

  config = mkMerge [
    (mkIf (config.ssd.enable) {
      # Enable periodic SSD TRIM of mounted partitions in the background
      services.fstrim.enable = true;
    })

    {
      # storage daemon required for udiskie auto-mount
      services.udisks2.enable = true;
    }
  ];
}
