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
        description = "Enable features for SSDs";
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

      # Add more supported file systems for removable drives
      boot.supportedFilesystems = [
        "ext4"
        "btrfs"
        "xfs"
        "ntfs"
        "fat"
        "vfat"
      ];

      # Trash support
      services.gvfs.enable = true;
    }
  ];
}
