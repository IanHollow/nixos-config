{
  config,
  lib,
  ...
}:
with lib; {
  # define custom option for intel_cpu
  options.intel_cpu = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };

    thermald = {
      enable = mkOption {
        type = types.bool;
        default = config.laptop.enable;
      };
    };
  };

  config = mkIf (config.intel_cpu.enable) {
    # Enable Intel CPU config
    boot.kernelModules = ["kvm-intel"];

    hardware.enableRedistributableFirmware = mkDefault true;
    hardware.cpu.intel.updateMicrocode = mkDefault config.hardware.enableRedistributableFirmware;

    # Enable thermald
    services.thermald.enable = config.intel_cpu.thermald.enable;
  };
}
