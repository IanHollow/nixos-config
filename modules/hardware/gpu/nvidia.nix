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
        nverProduction = config.boot.kernelPackages.nvidiaPackages.stable.version;
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
        open = true;

        # The Nvidia settings menu,
        # accessible via `nvidia-settings`.
        nvidiaSettings = true;

        # Uses beta version if it is newer than the production version
        package = nvidiaPackage;
      };

      # Nvidia DRM (Direct Rendering Manager) KMS (Kernel Mode Setting) support
      # NOTE: This is NOT the same as the other DRM (Digital Rights Management)
      # Based on Arch Wiki: https://wiki.archlinux.org/title/NVIDIA#DRM_kernel_mode_setting
      # Add kernel parameters to enable DRM KMS support
      # NOTE: The kernel patameters for Nvidia use "-" instead of "_"
      boot.kernelParams = [
        # "nvidia-drm.modeset=1" # Based on Arch Wiki (Already enabled by NixOS but as "nvidia-drm.modeset=1")
        "nvidia-drm.fbdev=1" # Based on Arch Wiki
      ];

      # Early loading KMS support for Nvidia
      # Based on NixOS Wiki: https://nixos.wiki/wiki/Nvidia#Booting_to_Text_Mode
      # Other Nvidia Kernel modules will be handled by NixOS as we don't want to load them out of order
      boot.initrd.kernelModules = ["nvidia"];
      boot.extraModulePackages = [config.boot.kernelPackages.nvidia_x11];
    })

    # Enable PRIME render offload
    (mkIf (config.nvidia_gpu.prime_render_offload.enable) {
      hardware.nvidia.prime = {
        offload = {
          enable = true; # Cannot be enabled alongside Nvidia Prime Sync
          # enableOffloadCmd = true; # Provides `nvidia-offload` command. (can rewrite to make own version of command with more env vars)
        };

        # sync.enable = true; # Cannot be enabled alongside Nvidia Prime Offload

        # reverseSync.enable = true;
        # allowExternalGpu = false; # Enable if using an external GPU

        # hardware-configuration.nix should specify the bus ID for integrated & nvidia gpus
      };

      # Install Extra Packages for Nvidia
      environment.systemPackages = [
        # Rewrote `nvidia-offload` command to include more environment variables
        # Based NixOS Wiki: https://nixos.wiki/wiki/Nvidia
        # Aditional env var of LIBVA_DRIVER_NAME=nvidia due to nvidia-vaapi-driver
        (pkgs.writeShellScriptBin "nvidia-offload" ''
          export __NV_PRIME_RENDER_OFFLOAD=1
          export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
          export __GLX_VENDOR_LIBRARY_NAME=nvidia
          export __VK_LAYER_NV_optimus=NVIDIA_only
          export LIBVA_DRIVER_NAME=nvidia
          exec "$@"
        '')
      ];
    })
  ];
}
