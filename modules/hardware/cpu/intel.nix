{
  config,
  lib,
  ...
}:
with lib; {
  # define custom option for intel_cpu
  options = {
    intel_cpu = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };

  config = mkIf (config.intel_cpu.enable) {
    boot.kernelModules = ["kvm-intel"];

    hardware.enableRedistributableFirmware = lib.mkDefault true;
    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}
