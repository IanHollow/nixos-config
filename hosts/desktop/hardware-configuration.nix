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

  boot.initrd.availableKernelModules = ["nvme" "ahci" "xhci_pci" "usbhid" "usb_storage" "sd_mod"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-amd"]; # TODO: add virtualization support through a module
  boot.extraModulePackages = [];

  # Enable the GPU
  nvidia_gpu.enable = true;

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
    wifiPowersave = false;
  };

  nixpkgs.hostPlatform = lib.mkDefault system;
  # powerManagement.cpuFreqGovernor = lib.mkDefault "powersave"; # TODO: figure out more about this option

  # Enable the CPU
  amd_cpu.enable = true;
}
