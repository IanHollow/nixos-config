{
  pkgs,
  unstable,
  config,
  lib,
  inputs,
  ...
}:
with lib; {
  # check if hyprland is enabled
  config = mkMerge [
    (mkIf (config.hyprland.enable) {
      # XDG Desktop Portals
      xdg.portal = {
        # Enable the portals
        enable = true;

        # Install portals needed for Hyprland
        extraPortals = let
          xdg-desktop-portal-hyprland = inputs.hyprland-xdph.packages.${pkgs.system}.xdg-desktop-portal-hyprland;
        in [
          xdg-desktop-portal-hyprland
          pkgs.xdg-desktop-portal-gtk
        ];

        config.hyprland = {
          # Set the default portal to Hyprland for all portal interfaces
          default = [
            "hyprland"
          ];

          # Overrides:
          # Set the File chooser portal to the gtk portal
          "org.freedesktop.impl.portal.FileChooser" = [
            "gtk"
          ];

          # Set the Secret portal interface to the gnome-keyring portal
          "org.freedesktop.impl.portal.Secret" = mkIf (config.keyring.enable) [
            "gnome-keyring"
          ];
        };
      };

      # Install packages for the Hyprland Desktop Portal
      environment.systemPackages = with pkgs; [
        grim
        slurp
      ];
    })
  ];
}
