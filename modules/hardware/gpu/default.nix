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
  environment.systemPackages = [
    pkgs.libva
    pkgs.libva-utils # Good for debugging VA-API with "vainfo"
    pkgs.glxinfo
    pkgs.lshw # Good for indentifying hardware
    unstable.ffmpeg-full
  ];
}
