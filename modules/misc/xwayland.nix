{
  pkgs,
  unstable,
  config,
  lib,
  ...
}:
with lib; {
  # Define options for xwaylandvideobridge
  options.xwaylandvideobridge = {
    enable = mkEnableOption "Enable the xwaylandvideobridge";
  };

  config = mkIf (config.xwaylandvideobridge.enable) {
    # Add xwaylandvideobridge to the system packages
    environment.systemPackages = [
      unstable.xwaylandvideobridge # XWayland Video Bridge
    ];
  };
}
