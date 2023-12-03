{
  config,
  lib,
  ...
}:
with lib; {
  # define custom option for amd_cpu
  options = {
    amd_cpu = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };

  config = mkIf (config.amd_cpu.enable) {
    boot.kernelModules = ["kvm-amd"];

    hardware.enableRedistributableFirmware = true;
    hardware.cpu.amd.updateMicrocode = config.hardware.enableRedistributableFirmware;
  };
}
