{
  pkgs,
  unstable,
  lib,
  ...
}: {
  imports =
    [./hardware-configuration.nix]
    ++ (import ../../modules/hardware)
    ++ (import ../../modules/boot)
    ++ (import ../../modules/desktops)
    ++ (import ../../modules/editors)
    ++ (import ../../modules/input-components)
    ++ (import ../../modules/development)
    ++ (import ../../modules/programs)
    ++ (import ../../modules/security)
    ++ (import ../../modules/shell)
    ++ (import ../../modules/theming);

  # Desktop Evironment / Desktop Manager
  hyprland = {
    enable = true;
    monitors = {
      primary = {
        enable = true;
        name = "eDP-1";
        resolution = {
          width = 3072;
          height = 1920;
        };
        refreshRate = 60;
        colorDepth = 10;
      };
    };
  };

  # Enable Audio
  pipewire.enable = true;

  # Enable Laptop Features
  laptop.enable = true;

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
      anki-bin # Flashcard App
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
