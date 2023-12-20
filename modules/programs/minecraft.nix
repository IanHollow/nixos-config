{
  pkgs,
  inputs,
  ...
}: {
  # TODO: add options to install specific minecraft launchers or not
  environment.systemPackages = [
    inputs.getchoo.packages.${pkgs.system}.modrinth-app
    pkgs.prismlauncher
  ];
}
