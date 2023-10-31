{
  inputs,
  pkgs,
  ...
}: {
  imports = [inputs.hyprland.nixosModules.default];

  programs.hyprland = {
    # Window Manager
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    xwayland.enable = true;
    enableNvidiaPatches = true;
  };

  # Electron and Chromium Apps Wayland Flags
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Display Manager
  services.xserver.enable = true;
  services.xserver.displayManager.sddm.enable = true;

  # XDG Desktop Portal
  xdg.portal = {
    enable = true;
    extraPortals = [pkgs.xdg-desktop-portal-gtk];
  };

  # Disable suspend/hibernate
  systemd.sleep.extraConfig = ''
    AllowSuspend=no
    AllowHibernation=no
    AllowSuspendThenHibernate=no
    AllowHybridSleep=no
  '';

  nix.settings = {
    substituters = ["https://hyprland.cachix.org"];
    trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
  };
}
