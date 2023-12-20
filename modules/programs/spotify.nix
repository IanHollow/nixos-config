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

  # TODO: find a way to fix this bug https://community.spotify.com/t5/Desktop-Linux/UI-Bug-Currently-playing-song-s-name-overlaps-with-Album-name/td-p/5618177
  #       I only have this problem when the gpu is Intel and not when it's Nvidia
  #       can add the --disable-gpu flag to spotify to fix it but then the gpu is not used at all

  # TODO: find a way to add flags to spotify for fcitx5 to work tested with flag --enable-wayland-ime and it works

  # configure spicetify :)
  programs.spicetify = {
    theme = spicePkgs.themes.Ziro;
    colorScheme = "green-dark";

    # use spotify from the nixpkgs unstable branch
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
