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
  boot.initrd.kernelModules = ["i915"]; # TODO: see if the i915 module is needed
  boot.kernelModules = ["kvm-intel"];
  boot.extraModulePackages = [];

  # GPU IDs
  hardware.nvidia.prime = {
    # Make sure to use the correct Bus ID values for your system!
    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:1:0:0";
  };

  # Enable the GPUs
  nvidia_gpu = {
    enable = true;
    prime_render_offload.enable = true;
  };
  intel_gpu = {
    enable = true;
    integrated.enable = true;
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
  networking = with host; {
    useDHCP = lib.mkDefault true;
    hostName = "nixos";
    enableIPv6 = false;
    networkmanager.enable = true;
    firewall = {
      enable = true;
      # if packets are still dropped, they will show up in dmesg
      logReversePathDrops = true;
      # wireguard trips rpfilter up
      extraCommands = ''
        ip46tables -t mangle -I nixos-fw-rpfilter -p udp -m udp --sport 51820 -j RETURN
        ip46tables -t mangle -I nixos-fw-rpfilter -p udp -m udp --dport 51820 -j RETURN
      '';
      extraStopCommands = ''
        ip46tables -t mangle -D nixos-fw-rpfilter -p udp -m udp --sport 51820 -j RETURN || true
        ip46tables -t mangle -D nixos-fw-rpfilter -p udp -m udp --dport 51820 -j RETURN || true
      '';
    }; # To load wireguard cert in nm-applet: nmcli connection import type wireguard file <config file>
  };

  # add user to networkmanager group
  users.users.${vars.user}.extraGroups = ["networkmanager"];

  nixpkgs.hostPlatform = lib.mkDefault system;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave"; # TODO: figure out more about this option

  # Enable the CPU
  intel_cpu.enable = true;
}
