{
  inputs = {
    # Nix Packages Stable and Unstable
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # Nix Systems
    systems.url = "github:nix-systems/default-linux";

    # Nix Flake Utils
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };

    # Nix User Repository (Community Packages)
    nur.url = github:nix-community/NUR;

    # Nix Home Manager
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Nix Packages for Wayland
    nixpkgs-wayland = {
      url = "github:nix-community/nixpkgs-wayland";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Hyprland
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

    # Spicetify for Spotify
    spicetify-nix = {
      url = "github:the-argus/spicetify-nix";
      inputs = {
        nixpkgs.follows = "nixpkgs-unstable";
        flake-utils.follows = "flake-utils";
      };
    };

    # Nix VSCode Extensions
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs = {
        nixpkgs.follows = "nixpkgs-unstable";
        flake-utils.follows = "flake-utils";
      };
    };

    # Modrinth Minecraft Launcher
    getchoo.url = "github:getchoo/nix-exprs";

    # Waybar
    waybar = {
      url = "github:Alexays/Waybar";
      flake = false;
    };

    # Theming
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
    nixosConfigurations = (
      import ./hosts {
        inherit (nixpkgs) lib;
        inherit inputs nixpkgs nixpkgs-unstable home-manager vars;
      }
    );
  };
}
