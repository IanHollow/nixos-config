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

    hardware.enableRedistributableFirmware = lib.mkDefault true;
    hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}
