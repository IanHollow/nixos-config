{
  config,
  lib,
  pkgs,
  modulesPath,
  host,
  vars,
  system,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = ["nvme" "thunderbolt" "xhci_pci" "usbhid" "usb_storage" "sd_mod" "ums_realtek"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = [];
  boot.extraModulePackages = [];

  # Firmware Updates
  services.fwupd.enable = true;
  hardware.enableAllFirmware = true;

  # GPU IDs
  hardware.nvidia.prime = {
    # Make sure to use the correct Bus ID values for your system!
    intelBusId = "PCI:0:2:0"; # card 0
    nvidiaBusId = "PCI:1:0:0"; # card 1
  };

  # Enable the GPUs
  nvidia_gpu = {
    enable = true;
    direct_backend = true;
    prime_render_offload.enable = true;
  };
  intel_gpu = {
    enable = true;
    integrated.enable = true;

    # For my Intel Gen11 CPU
    guc.enable = true;
    huc.enable = true;
  };

  # Enable the SSD
  ssd.enable = true;

  # Set the root partition
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  # Set the boot partition
  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };

  # Set the swap partition
  swapDevices = [{device = "/dev/disk/by-label/swap";}];

  # Networking
  custom_networking = {
    enable = true;
    autoHostId = true;
    wireguard = true;
    cloudflareDNS = true;
    radomizeMacAddress = true;
    wifiPowersave = true;
  };

  # Define the host platform
  nixpkgs.hostPlatform = lib.mkDefault system;

  # Enable the CPU
  intel_cpu = {
    enable = true;
    thermald.enable = true;
  };

  # Enable auto-cpufreq
  auto-cpufreq.enable = true;
}
