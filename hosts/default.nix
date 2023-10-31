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
    config.allowUnfree = true;
  };

  unstable = import nixpkgs-unstable {
    inherit system;
    config.allowUnfree = true;
  };
in {
  Desktop = nixpkgs.lib.nixosSystem {
    # Desktop Profile
    inherit system;
    specialArgs = {
      inherit inputs system unstable vars;
      host = {
        hostName = "nixos_desktop";
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
