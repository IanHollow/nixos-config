{ lib, pkgs, vars, ... }:

{
  imports = [ ./hardware-configuration.nix ] ++
    (import ../../modules/desktops) ++
    (import ../../modules/programs) ++
    (import ../../modules/shell);

  # Boot Loader Setup
  boot.loader = {
    timeout = 5;
    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      useOSProber = true;
      configurationLimit = 10;
    };
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
  };

  # Kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;
}
