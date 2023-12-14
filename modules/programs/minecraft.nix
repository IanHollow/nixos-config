{
  pkgs,
  inputs,
  ...
}: {
  environment.systemPackages = [
    inputs.getchoo.packages.${pkgs.system}.modrinth-app
    pkgs.prismlauncher
  ];
}
