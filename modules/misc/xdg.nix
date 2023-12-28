{
  pkgs,
  unstable,
  config,
  lib,
  ...
}:
with lib; {
  # custom options for the default xdg desktop portal config
  options.custom_xdg = {
    portals = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable the default xdg desktop portals";
      };
    };
  };

  # the config for the default xdg desktop portal
  config = mkMerge [
    (mkIf (config.custom_xdg.portals.enable) {
      xdg.portal = {
        # Enable the desktop portals
        enable = true;

        # Install the default xdg desktop portal
        extraPortals = [
          pkgs.xdg-desktop-portal-gtk
        ];

        # Define the common config for the portals
        # NOTE: the common config will only be used if no other config is defined for a for a specfic desktop
        config.common = {
          # Set the default portal for every portal interface
          default = [
            "gtk"
          ];

          # Overrides:
          # NOTE: These will override the default portal for each portal interface configured.
          #       Use "org.freedesktop.impl.portal.${name_of_portal}" to set an portal override
          # Set the Secret portal interface to the gnome-keyring portal
          "org.freedesktop.impl.portal.Secret" = mkIf (config.keyring.enable) [
            "gnome-keyring"
          ];
        };
      };

      # Install extra packages
      environment.systemPackages = with pkgs; [
        xdg-utils # XDG Utilities needed for xdg-open
      ];
    })
  ];
}
