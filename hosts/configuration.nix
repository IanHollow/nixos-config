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
        # Desktop Environment
        waybar
        #eww-wayland
        rofi-wayland
        # Settings Programs
        pavucontrol
        playerctl
        networkmanagerapplet
        blueman
        dconf

        # nix editor packages
        nixpkgs-fmt
        rnix-lsp
        alejandra
        # Command Line Programs
        wget
        curl
        zip
        unzip
        neofetch
        htop
        git
        gh

        # Programming
        gcc
        gnumake
        valgrind
        gdb
        # Other Programs
        ranger
      ]
      ++ (with unstable; [
        ]);
  };

  programs.dconf.enable = true;

  nix = {
    # Nix Package Manager Settings
    settings.auto-optimise-store = true;

    gc = {
      # Garbage Collection
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    settings.experimental-features = ["nix-command" "flakes"]; # Enable Flakes
    settings.keep-outputs = true;
    settings.keep-derivations = true;

    package = pkgs.nixVersions.unstable;
  };

  nixpkgs.config.allowUnfree = true; # Allow Proprietary Software.

  home-manager.users.${vars.user} = {
    # Home-Manager Settings
    home.stateVersion = "23.05";
    programs.home-manager.enable = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
