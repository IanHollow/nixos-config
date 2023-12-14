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
    ++ (import ../../modules/services)
    ++ (import ../../modules/shell)
    ++ (import ../../modules/theming);

  # Desktop Evironment / Desktop Manager
  hyprland.enable = true;

  # Enable the GPU
  nvidia_gpu = {
    enable = true;
    prime_render_offload.enable = true;
  };
  intel_gpu = {
    enable = true;
    integrated.enable = true;
  };

  # Enable Audio
  pipewire.enable = true;

  # Enable Laptop Features
  laptop.enable = true;

  # Enable Bootloader
  grub.enable = true;

  # Set the Kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # System-Wide Packages
  environment.systemPackages = with pkgs;
    [
      # Media/Video
      okular # PDF Viewer
      gwenview # Image Viewer
      mpv # Video Player
      anki-bin
    ]
    ++ (with unstable; [
      # Apps
      bitwarden # Password Manager
      zoom-us # Video Conferencing
      slack # Messaging
      telegram-desktop # Messaging
    ]);

  firefox.enable = true;
}
