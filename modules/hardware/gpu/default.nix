{
  pkgs,
  unstable,
  ...
}: {
  imports = [
    ./nvidia.nix
    ./intel.nix
  ];

  # TODO: create global variable that defines a multi gpu system is enabled

  # TODO: check that at least one gpu is enabled to install packages below

  # Install Extra Packages needed regardless of GPU
  environment.systemPackages = [
    # Tools for debugging
    pkgs.libva
    pkgs.libva-utils # Good for debugging VA-API with "vainfo"
    pkgs.glxinfo
    pkgs.lshw # Good for indentifying hardware

    # Hardware acceleration
    unstable.ffmpeg-full # TODO: explain why this is needed

    # Vulkan
    pkgs.vulkan-loader
    pkgs.vulkan-tools
    pkgs.vulkan-validation-layers
    pkgs.vulkan-headers
    pkgs.vulkan-utility-libraries
    pkgs.vulkan-extension-layer
  ];

  # Set environment variables for all gpus
  environment.sessionVariables = {
    WLR_RENDERER = "vulkan"; # Assuming that all gpus are vulkan capable
  };
}
