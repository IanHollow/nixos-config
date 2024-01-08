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
        default = false || config.intel_gpu.integrated.enable;
      };

      # To find out if it is a integrated GPU
      integrated = {
        enable = mkOption {
          type = types.bool;
          default = true; # makes sense to assume that intel_gpu is integrated as it is more likely
        };
      };

      # Enable GuC Submission
      guc = {
        enable = mkOption {
          type = types.bool;
          default = false;
          description = ''
            Enable GuC Submission.
            Supported by Alder Lake-P (Mobile) and newer (Gen12+).
            Despite Intel's documentation Tiger Lake & Rocket Lake (Gen11) support GuC Submission.
            Read https://wiki.archlinux.org/title/intel_graphics#Enable_GuC_/_HuC_firmware_loading before enabling.
          '';
        };
      };

      # Enable HuC Firmware Loading
      huc = {
        enable = mkOption {
          type = types.bool;
          default = false;
          description = "
          Enable HuC Firmware Loading. Supported by Gen9 Intel and above.
          Read https://wiki.archlinux.org/title/intel_graphics#Enable_GuC_/_HuC_firmware_loading before enabling.
          ";
        };
      };
    };
  };

  # TODO: add force disable of intel integrated graphics with kernel parameter "boot.kernelParams = [ "module_blacklist=i915" ];"

  config = mkMerge [
    (mkIf (config.intel_gpu.enable) {
      boot.initrd.kernelModules = ["i915"];

      environment.variables = {
        VDPAU_DRIVER = lib.mkIf config.hardware.opengl.enable (lib.mkDefault "va_gl");
      };

      hardware.opengl = {
        enable = true;
        driSupport = true;
        driSupport32Bit = true;

        extraPackages = with pkgs; [
          intel-vaapi-driver # replaces package "vaapiIntel" as of Nix 23.11
          libvdpau-va-gl
          intel-media-driver
        ];

        extraPackages32 = with pkgs.pkgsi686Linux; [
          intel-vaapi-driver # replaced old vaapiIntel in Nix 23.11
          libvdpau-va-gl
          intel-media-driver
        ];
      };
    })

    # Guc and HuC
    # DOCS: https://wiki.archlinux.org/title/intel_graphics#Enable_GuC_/_HuC_firmware_loading
    # NOTE: GuC and HuC are enabled by default on Alder Lake-P (Mobile) and newer (Gen12+).
    # Despite Intel's documentation Tiger Lake & Rocket Lake (Gen11) should support GuC and HuC
    #       but it is not enabled by default and instead only has GuC Submission enabled by default.
    # WARNING: Manually enabling GuC / HuC firmware loading taints the kernel even when the feature is not supported.
    #          Moreover, enabling GuC/HuC firmware loading can cause issues on some systems;
    #          disable it if you experience freezing (for example, after resuming from hibernation).
    (mkIf (config.intel_gpu.enable && config.intel_gpu.integrated.enable && (config.intel_gpu.guc.enable || config.intel_gpu.huc.enable)) {
      boot.kernelParams = let
        # Value based on documentation from https://wiki.archlinux.org/title/intel_graphics#Enable_GuC_/_HuC_firmware_loading
        value =
          # 3 = GuC and HuC
          if (config.intel_gpu.guc.enable && config.intel_gpu.huc.enable)
          then "3"
          # 1 = GuC only
          else if (config.intel_gpu.guc.enable && !config.intel_gpu.huc.enable)
          then "1"
          # 2 = HuC only
          else if (config.intel_gpu.huc.enable && !config.intel_gpu.guc.enable)
          then "2"
          # this option will never happen as this module is only enabled if either GuC or HuC is enabled
          else "0";
      in ["i915.enable_guc=${value}"];
    })
  ];
}
