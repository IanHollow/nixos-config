{
  inputs,
  pkgs,
  lib,
  unstable,
  ...
}: let
  spicePkgs = inputs.spicetify-nix.packages.${pkgs.system}.default;
in {
  # allow spotify to be installed if you don't have unfree enabled already
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "spotify"
    ];

  # import the flake's module for your system
  imports = [inputs.spicetify-nix.nixosModules.default];

  # configure spicetify :)
  programs.spicetify = {
    theme = spicePkgs.themes.Ziro;
    colorScheme = "gray-dark";

    # use spotify from the nixpkgs master branch
    spotifyPackage = unstable.spotify;
    spicetifyPackage = unstable.spicetify-cli;

    # actually enable the installation of spotify and spicetify
    enable = true;

    enabledExtensions = with spicePkgs.extensions; [
      shuffle # shuffle+ (special characters are sanitized out of ext names)
      adblock
      volumePercentage
    ];

    enabledCustomApps = with spicePkgs.apps; [
      new-releases
      lyrics-plus
    ];
  };
}
