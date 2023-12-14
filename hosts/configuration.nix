{
  config,
  lib,
  pkgs,
  unstable,
  inputs,
  vars,
  ...
}: {
  users.users.${vars.user} = {
    # System User
    isNormalUser = true;
    extraGroups = ["wheel" "video" "audio"];
    initialPassword = "password"; # IMPORTANT: change this with passwd command for your user
  };

  time.timeZone = "America/Los_Angeles"; # Time zone and Internationalisation

  environment = {
    systemPackages = with pkgs;
      [
        # Command Line Programs
        busybox
        curl
        neofetch
        htop # TODO: configure htop or find a better alternative also allow for gpu monitoring
        git # TODO: add git and gh to the development folder with a configuation applied
        gh
      ]
      ++ (with unstable; [
        ]);
  };

  nix = {
    gc = {
      # Garbage Collection
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
      randomizedDelaySec = "30min";
    };
    # Nix Package Manager Settings
    settings = rec {
      auto-optimise-store = true;
      experimental-features = ["nix-command" "flakes"]; # Enable Flakes

      keep-derivations = true;
      keep-outputs = true;

      builders-use-substitutes = true;
      cores = lib.mkDefault 0;
      max-jobs = lib.mkDefault "auto";
      use-xdg-base-directories = true;
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      ];
      trusted-substituters = [
        "https://cache.nixos.org"
        "https://nixpkgs-wayland.cachix.org"
        "https://nix-community.cachix.org"
        "https://cache.garnix.io"
      ];
      substituters = trusted-substituters;
      trusted-users = ["@wheel" "${vars.user}" "root"];
    };
  };

  nixpkgs.config.allowUnfree = true; # Allow Proprietary Software.

  home-manager.users.${vars.user} = {
    # Home-Manager Settings
    home.stateVersion = "23.11";
    programs.home-manager.enable = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
