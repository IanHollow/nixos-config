{
  pkgs,
  unstable,
  lib,
  config,
  ...
}:
with lib; {
  # define custom option for grub
  options = {
    grub = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };

  config = mkIf (config.grub.enable) {
    boot = {
      # Boot Options
      loader = {
        efi = {
          canTouchEfiVariables = true;
          efiSysMountPoint = "/boot";
        };
        # TODO: Theme Grub
        grub = {
          # Grub Dual Boot
          enable = true;
          devices = ["nodev"];
          efiSupport = true;
          useOSProber = true; # Find All boot Options
          configurationLimit = 10;
          default = 0; # chooses nixos for boot (set 2 to boot to another OS (windows) if desired)
        };
        timeout = 5;
      };
    };
  };
}
