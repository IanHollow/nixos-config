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
  boot.kernelModules = [];
  boot.extraModulePackages = [];

  # Firmware Updates
  services.fwupd.enable = true;
  hardware.enableAllFirmware = true;

  # Enable the GPU
  nvidia_gpu = {
    enable = true;
    direct_backend = true;
    open_kernel_modules.enable = true;
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

  # Set shared Windows Games partition
  fileSystems."/mnt/games" = {
    device = "/dev/disk/by-label/games";
    fsType = "ntfs";
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

  # Bluetooth
  bluetooth.enable = true;
}
