{
  pkgs,
  unstable,
  config,
  lib,
  ...
}:
with lib; {
  options.bluetooth = {
    enable = mkEnableOption "Enable Bluetooth support";
  };

  # TODO: make sure this is the right way to enable bluetooth
  config = mkIf (config.bluetooth.enable) {
    hardware.bluetooth.enable = true; # enables support for Bluetooth
    hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
    services.blueman.enable = true;
    hardware.bluetooth.settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
      };
    };
  };
}
