{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    systems.url = "github:nix-systems/default-linux";

    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };

    nur.url = github:nix-community/NUR;

    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland-protocols = {
      url = "github:hyprwm/hyprland-protocols";
      inputs = {
        systems.follows = "systems";
        nixpkgs.follows = "nixpkgs-unstable";
      };
    };

    hyprland-xdph = {
      url = "github:hyprwm/xdg-desktop-portal-hyprland";
      inputs = {
        systems.follows = "systems";
        nixpkgs.follows = "nixpkgs-unstable";
        hyprland-protocols.follows = "hyprland-protocols";
      };
    };

    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs = {
        systems.follows = "systems";
        nixpkgs.follows = "nixpkgs-unstable";
        hyprland-protocols.follows = "hyprland-protocols";
        xdph.follows = "hyprland-xdph";
      };
    };

    hyprland-nix = {
      url = "github:hyprland-community/hyprland-nix";
      inputs = {
        hyprland.follows = "hyprland";
        hyprland-xdph.follows = "hyprland-xdph";
        hyprland-protocols.follows = "hyprland-protocols";
      };
    };

    spicetify-nix = {
      url = "github:the-argus/spicetify-nix";
      inputs = {
        nixpkgs.follows = "nixpkgs-unstable";
        flake-utils.follows = "flake-utils";
      };
    };

    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs = {
        nixpkgs.follows = "nixpkgs-unstable";
        flake-utils.follows = "flake-utils";
      };
    };

    getchoo.url = "github:getchoo/nix-exprs";

    # themes
    catppuccin-fcitx5 = {
      url = "github:catppuccin/fcitx5";
      flake = false;
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    nixpkgs-unstable,
    home-manager,
    ...
  }: let
    vars = {
      user = "ianmh";
    };
  in {
    nixosConfigurations = ( # NixOS Configurations
      import ./hosts {
        inherit (nixpkgs) lib;
        inherit inputs nixpkgs nixpkgs-unstable home-manager vars; # Inherit inputs
      }
    );
  };
}
