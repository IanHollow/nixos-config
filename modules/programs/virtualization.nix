{
  pkgs,
  unstbale,
  vars,
  config,
  lib,
  ...
}:
with lib; let
  platform =
    if (config.intel_cpu.enable)
    then "intel"
    else if (config.amd_cpu.enable)
    then "amd"
    else null;
in {
  options.custom_virtualisation = {
    enable = mkEnableOption "Enable Virtualisation support";
  };

  config = mkIf (config.custom_virtualisation.enable) {
    assertions = [
      {
        assertion = platform != null;
        message = "Virtualization: Platform must be either Intel or AMD. Please enable one of them.";
      }
    ];

    users.groups = {
      libvirtd.members = ["root" "${vars.user}"];
      kvm.members = ["root" "${vars.user}"];
    };

    virtualisation = {
      libvirtd = {
        enable = true;

        # Don't start any VMs automatically on boot.
        onBoot = "ignore";

        # Stop all running VMs on shutdown.
        onShutdown = "shutdown";

        qemu = {
          package = pkgs.qemu_kvm;
          ovmf.enable = true;
          verbatimConfig = ''
            nvram = [ "${pkgs.OVMF}/FV/OVMF.fd:${pkgs.OVMF}/FV/OVMF_VARS.fd" ]
          '';
          swtpm.enable = true; # For TPM
        };
      };
      spiceUSBRedirection.enable = true;
    };

    programs.virt-manager.enable = true;

    environment.systemPackages = with pkgs; [
      virt-viewer # Remote VM
      qemu # Virtualizer
      OVMF # UEFI Firmware
      swtpm # TPM
    ];

    boot = {
      kernelModules =
        # For KVM support
        ["kvm-${platform}"]
        # For passthrough support
        ++ [
          "vfio"
          "vfio_iommu_type1"
          "vfio_pci"
          "vfio_virqfd"
        ];

      # Kernel Parameters for passthrough support
      kernelParams = [
        "${platform}_iommu=on"
        "${platform}_iommu=pt"
        "kvm.ignore_msrs=1"
      ];
    };

    home-manager.users.${vars.user} = {
      # To deal with startup issues on virt-manager: https://nixos.wiki/wiki/Virt-manager
      dconf.settings = {
        "org/virt-manager/virt-manager/connections" = {
          autoconnect = ["qemu:///system"];
          uris = ["qemu:///system"];
        };
      };
    };
  };
}
