{
  lib,
  inputs,
  nixpkgs,
  nixpkgs-unstable,
  home-manager,
  vars,
  ...
}: let
  system = "x86_64-linux"; # System Architecture

  pkgs = import nixpkgs {
    inherit system;
    config.allowUnfree = true; # Allow Proprietary Software
  };

  unstable = import nixpkgs-unstable {
    inherit system;
    config.allowUnfree = true;
  };

  lib = nixpkgs.lib;
in {
  # Desktop Profile
  desktop = lib.nixosSystem {
    # Desktop Profile
    inherit system;
    specialArgs = {
      # Pass Flake Variable
      inherit inputs system unstable vars;
      host = {
        hostName = "desktop";
      };
    };
    modules = [
      # Modules Used
      ./desktop
      ./configuration.nix

      home-manager.nixosModules.home-manager
      {
        # Home-Manager Module
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
      }
    ];
  };

  # Laptop Profile
  laptop = lib.nixosSystem {
    # Desktop Profile
    inherit system;
    specialArgs = {
      # Pass Flake Variable
      inherit inputs system unstable vars;
      host = {
        hostName = "laptop";
      };
    };
    modules = [
      # Modules Used
      ./laptop
      ./configuration.nix

      home-manager.nixosModules.home-manager
      {
        # Home-Manager Module
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
      }
    ];
  };
}
