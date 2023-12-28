{
  config,
  lib,
  pkgs,
  unstable,
  inputs,
  vars,
  ...
}: {
  imports = (
    import ../modules/hardware
    ++ import ../modules/desktop-envs
    ++ import ../modules/display-managers
    ++ import ../modules/misc
    ++ import ../modules/input
    ++ import ../modules/development
    ++ import ../modules/programs
    ++ import ../modules/security
    ++ import ../modules/shell
    ++ import ../modules/theming
  );

  # TODO: consider removing support for X11 (only support wayland)

  users.users.${vars.user} = {
    # System User
    isNormalUser = true;
    extraGroups = ["wheel" "video"];

    # Set initial password for the user
    # IMPORTANT: change this with passwd ${username} command for your user
    initialPassword = "password";
  };

  time.timeZone = "America/Los_Angeles"; # Time zone and Internationalisation

  environment = {
    # NOTE: Most of these packages are from github:spikespaz/dotfiles/hosts/common/packages.nix
    systemPackages = with pkgs;
      [
        # Command Line Programs
        gh # TODO: add git and gh to the development folder with a configuation applied
        bc
        tree

        ### CLI UTILITIES ###
        fastfetch # neofetch but made in c
        wget # simple downloader utility
        curl # network request utility
        p7zip # archive and compression tool
        git # version control
        zip # archive utility
        unzip # archive utility
        bat # cat with wings
        fzf # fuzzy finder
        eza # colored alternative to ls
        ripgrep # grep but rust
        sd # sed but rust
        # tealdear      # manpage summaries

        ################
        ### HARDWARE ###
        ################

        ### SYSTEM DEVICES ###
        config.boot.kernelPackages.cpupower
        v4l-utils # proprietary media hardware and encoding
        pciutils # utilities for pci and pcie devices

        ### STORAGE DEVICE DRIVERS ###
        cryptsetup
        ntfs3g
        exfatprogs

        ### STORAGE DEVICE TOOLS ###
        gptfdisk
        e2fsprogs

        ### HARDWARE DIAGNOSTICS ###
        smartmontools # for drive SMART status
        btop # system process monitor
        bottom # not top
        procs # process viewer
        du-dust # du but rust
        bandwhich # network monitor

        ### VIRTUALIZATION ###
        libguestfs # filesystem driver for vm images
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
    settings = let
      # Define trusted public keys for Nix Cache
      my_keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];

      # Define the substituters for Nix Cache
      my_substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        "https://cache.garnix.io"
        "https://hyprland.cachix.org"
      ];
    in {
      auto-optimise-store = true;
      experimental-features = ["nix-command" "flakes"]; # Enable Flakes

      keep-derivations = true;
      keep-outputs = true;

      builders-use-substitutes = true;
      cores = lib.mkDefault 0;
      max-jobs = lib.mkDefault "auto";
      use-xdg-base-directories = true;
      trusted-public-keys = my_keys;
      trusted-substituters = my_substituters;
      substituters = my_substituters;
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
