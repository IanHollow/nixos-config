{
  pkgs,
  unstable,
  lib,
  ...
}: {
  # TODO: add message that explains how this config file works with the custom options that enable modules

  imports = [./hardware-configuration.nix];

  # Desktop Evironment
  hyprland = {
    enable = true;
    monitors = {
      primary = {
        enable = true;
        name = "DP-1";
        resolution = {
          width = 2560;
          height = 1440;
        };
        refreshRate = 165;
        colorDepth = 10;
      };
    };
  };

  # Enable Audio
  audio.enable = true;

  # Enable Bootloader
  grub.enable = true;

  # Set the Kernel
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;

  # System-Wide Packages
  environment.systemPackages = with pkgs;
    [
      # Media/Video
      okular # PDF Viewer
      gwenview # Image Viewer
      mpv # Video Player
      anki-bin # Flashcard Program
    ]
    ++ (with unstable; [
      # Apps
      bitwarden # Password Manager
      zoom-us # Video Conferencing
      slack # Messaging
      telegram-desktop # Messaging
    ]);

  # Enable Firefox
  firefox.enable = true;
}
