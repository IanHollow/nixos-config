{
  lib,
  inputs,
  nixpkgs,
  nixpkgs-unstable,
  home-manager,
  vars,
  system,
  ...
}: let
  pkgs = import nixpkgs {
    inherit system;
    config.allowUnfree = true; # Allow Proprietary Software
  };

  unstable = import nixpkgs-unstable {
    inherit system;
    config.allowUnfree = true;
  };
in {
  nixosDesktop = nixpkgs.lib.nixosSystem {
    # Desktop Profile
    inherit system;
    specialArgs = {
      inherit inputs system unstable vars;
      host = {
        hostName = "nixosDesktop";
      };
    };
    modules = [
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
}
