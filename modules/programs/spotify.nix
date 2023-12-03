{
  inputs,
  pkgs,
  unstable,
  ...
}: let
  spicePkgs = inputs.spicetify-nix.packages.${pkgs.system}.default;
in {
  # import the flake's module for your system
  imports = [inputs.spicetify-nix.nixosModules.default];

  # TODO: add options to enable/disable spotify and spicetify

  # configure spicetify :)
  programs.spicetify = {
    theme = spicePkgs.themes.Ziro;
    colorScheme = "green-dark";

    # use spotify from the nixpkgs master branch
    spotifyPackage = unstable.spotify;
    spicetifyPackage = unstable.spicetify-cli;

    # actually enable the installation of spotify and spicetify
    enable = true;

    enabledExtensions = with spicePkgs.extensions; [
      adblock
      volumePercentage
    ];

    enabledCustomApps = with spicePkgs.apps; [
      new-releases
      lyrics-plus
    ];
  };
}
