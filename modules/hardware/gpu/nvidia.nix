{
  lib,
  config,
  pkgs,
  unstable,
  inputs,
  ...
}:
with lib; let
  nverProduction = config.boot.kernelPackages.nvidiaPackages.stable.version;
  nverBeta = config.boot.kernelPackages.nvidiaPackages.beta.version;
  nvidiaPackage =
    if (lib.versionOlder nverBeta nverProduction)
    then config.boot.kernelPackages.nvidiaPackages.production
    else config.boot.kernelPackages.nvidiaPackages.beta;
in {
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

        # TODO: Check what packages are needed
        # Add Extra Packages for Nvidia
        extraPackages = with pkgs; [nvidia-vaapi-driver libva libva-utils];
        extraPackages32 = with pkgs.pkgsi686Linux; [nvidia-vaapi-driver];
      };

      # Load nvidia driver for Xorg and Wayland
      services.xserver.videoDrivers = ["nvidia"];

      hardware.nvidia = {
        # Modesetting is required.
        modesetting.enable = true;

        # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
        powerManagement.enable = config.laptop.enable;
        # Fine-grained power management. Turns off GPU when not in use.
        # Experimental and only works on modern Nvidia GPUs (Turing or newer).
        powerManagement.finegrained = config.laptop.enable;

        # Use the NVidia open source kernel module (not to be confused with the
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
    })

    # Enable PRIME render offload
    (mkIf (config.nvidia_gpu.prime_render_offload.enable) {
      hardware.nvidia.prime = {
        offload = {
          enable = true;
          enableOffloadCmd = true; # Provides `nvidia-offload` command.
        };
        # hardware-configuration.nix should specify the bus ID for integrated & nvidia gpus
      };
    })
  ];
}
