{
  lib,
  config,
  pkgs,
  unstable,
  inputs,
  ...
}:
with lib; {
  options = {
    # Enable Nvidia GPU
    nvidia_gpu = {
      # Condition if host uses an Nvidia GPU
      enable = mkOption {
        type = types.bool;
        default = false || nvidia_gpu.prime_render_offload.enable;
      };

      # Enable direct backend for Nvidia
      direct_backend = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Enable direct backend for Nvidia.
        ''; # TODO: add note to documentation about this option
      };

      # Enable PRIME render offload
      prime_render_offload = {
        # Condition if host wants to use PRIME render offload
        enable = mkOption {
          type = types.bool;
          default = false;
        };
      };
    };
  };

  config = mkMerge [
    # Enable Nvidia GPU
    (mkIf (config.nvidia_gpu.enable) {
      # Enable OpenGL
      hardware.opengl = {
        enable = true;
        driSupport = true;
        driSupport32Bit = true;

        # Add Extra Packages for Nvidia
        extraPackages = with pkgs; [
          nvidia-vaapi-driver
        ];
        extraPackages32 = with pkgs.pkgsi686Linux; [
          nvidia-vaapi-driver
        ];
      };

      # Load nvidia driver for Xorg and Wayland
      services.xserver.videoDrivers = ["nvidia"];

      hardware.nvidia = let
        # TODO: add module to enable beta driver
        nverProduction = config.boot.kernelPackages.nvidiaPackages.production.version;
        nverBeta = config.boot.kernelPackages.nvidiaPackages.beta.version;
        nvidiaPackage =
          if (lib.versionOlder nverBeta nverProduction)
          then config.boot.kernelPackages.nvidiaPackages.production
          else config.boot.kernelPackages.nvidiaPackages.beta;
      in {
        # Modesetting is required.
        modesetting.enable = true;

        # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
        powerManagement.enable = config.laptop.enable;
        # Fine-grained power management. Turns off GPU when not in use.
        # Experimental and only works on modern Nvidia GPUs (Turing or newer).
        # Requires Nvidia offload to be enabled.
        powerManagement.finegrained = config.hardware.nvidia.prime.offload.enable || config.hardware.nvidia.prime.reverseSync.enable;

        # Use the Nvidia open source kernel module (not to be confused with the
        # independent third-party "nouveau" open source driver).
        # Support is limited to the Turing and later architectures. Full list of
        # supported GPUs is at:
        # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
        # Only available from driver 515.43.04+
        # Do not disable this unless your GPU is unsupported or if you have a good reason to.
        # NOTE: Due to issue https://github.com/NVIDIA/open-gpu-kernel-modules/issues/472
        #       open kernel modules cannot be ennabled with hardware.nvidia.powerManagement.enabled set to true
        open = !config.hardware.nvidia.powerManagement.enable;

        # The Nvidia settings menu,
        # accessible via `nvidia-settings`.
        nvidiaSettings = true;

        # Uses beta version if it is newer than the production version
        package = nvidiaPackage;

        # Nvidia Prime
        prime = {
          # Enable Nvidia Prime Offload
          offload.enable = config.nvidia_gpu.prime_render_offload.enable;
        };
      };

      # Nvidia DRM (Direct Rendering Manager) KMS (Kernel Mode Setting) support
      # NOTE: This is NOT the same as the other DRM (Digital Rights Management)
      # Based on Arch Wiki: https://wiki.archlinux.org/title/NVIDIA#DRM_kernel_mode_setting
      # Add kernel parameters to enable DRM KMS support
      # NOTE: The kernel patameters for Nvidia use "-" instead of "_" which the Nvidia kernel modules use
      boot.kernelParams =
        [
          # "nvidia-drm.modeset=1" # Already enabled by NixOS but as "nvidia-drm.modeset=1"
          "nvidia-drm.fbdev=1" # Based on Arch Wiki
        ]
        # Enable Fix for Nvidia Suspend/WakeUp
        ++ optionals (config.hardware.nvidia.powerManagement.enable) ["nvidia.NVreg_PreserveVideoMemoryAllocations=1"];

      # Early loading KMS support for Nvidia
      # Based on NixOS Wiki: https://nixos.wiki/wiki/Nvidia#Booting_to_Text_Mode
      # Also Based on Arch Wiki: https://wiki.archlinux.org/title/NVIDIA#Early_loading
      # NOTE: VA-API will not work if Nvidia module "nvidia_uvm" is not loaded.
      boot.initrd.kernelModules = ["nvidia" "nvidia_modeset" "nvidia_drm"];
      boot.kernelModules = ["nvidia_uvm"];
      boot.extraModulePackages = [config.boot.kernelPackages.nvidia_x11];

      # Install Extra Packages for Nvidia
      environment.systemPackages =
        []
        # Rewrote `nvidia-offload` command to include more environment variables
        # Based NixOS Wiki: https://nixos.wiki/wiki/Nvidia
        # Aditional env var of LIBVA_DRIVER_NAME=nvidia due to nvidia-vaapi-driver
        ++ optionals (config.nvidia_gpu.prime_render_offload.enable)
        [
          (pkgs.writeShellScriptBin "nvidia-offload" ''
            export __NV_PRIME_RENDER_OFFLOAD=1
            export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
            export __GLX_VENDOR_LIBRARY_NAME=nvidia
            export __VK_LAYER_NV_optimus=NVIDIA_only
            export LIBVA_DRIVER_NAME=nvidia
            exec "$@"
          '')
        ];

      # Enable Extra environment variables for Nvidia
      environment.sessionVariables = {
        NVD_BACKEND = mkIf (config.nvidia_gpu.direct_backend) "direct";
      };
    })
  ];
}
