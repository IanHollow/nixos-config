{
  config,
  lib,
  pkgs,
  unstable,
  ...
}:
with lib; {
  options = {
    # Enable Intel GPU
    intel_gpu = {
      # To find out if their is Intel GPU
      enable = mkOption {
        type = types.bool;
        default = false;
      };

      # To find out if it is a integrated GPU
      integrated = {
        enable = mkOption {
          type = types.bool;
          default = false;
        };
      };
    };
  };

  config = mkIf (config.intel_gpu.enable) {
    boot.initrd.kernelModules = ["i915"];

    environment.variables = {
      VDPAU_DRIVER = lib.mkIf config.hardware.opengl.enable (lib.mkDefault "va_gl");
    };

    hardware.opengl = {
      enable = true;
      driSupport = true;

      # TODO: Check what packages are needed
      extraPackages = with pkgs; [
        libva
        libva-utils
        libvdpau
        (
          if (lib.versionOlder (lib.versions.majorMinor lib.version) "23.11")
          then vaapiIntel
          else intel-vaapi-driver
        )
        libvdpau-va-gl
        intel-media-driver
      ];
    };
  };
}
