{
  pkgs,
  inputs,
  ...
}: {
  # TODO: add options to install specific minecraft launchers or not
  # TODO: add firewall rules to allow for LAN play
  environment.systemPackages = [
    inputs.getchoo.packages.${pkgs.system}.modrinth-app
    pkgs.prismlauncher
  ];
}
