{
  pkgs,
  unstable,
  ...
}: {
  # TODO: add option to enable/disable discord
  environment.systemPackages = with unstable; [
    webcord-vencord
  ];
}
