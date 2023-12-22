{
  pkgs,
  unstable,
  condig,
  lib,
  ...
}:
with lib; {
  # TODO: create option to enable and disable features for xwayland

  environment.systemPackages = [
    unstable.xwaylandvideobridge # XWayland Video Bridge
  ];
}
