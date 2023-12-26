{
  pkgs,
  config,
  lib,
  ...
}: {
  # TODO: add more time options
  services.timesyncd.enable = true;
}
