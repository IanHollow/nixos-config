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
    allowTearing = true;
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
        vrr = true;
      };
    };
  };

  # Enable Audio
  audio = {
    enable = true;
    NoiseSuppressionForVoice = {
      enable = true;
    };
  };

  # Enable Bootloader
  grub.enable = true;

  # Set the Kernel
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;

  # Enable virtualization
  custom_virtualisation.enable = true;

  # System-Wide Packages
  environment.systemPackages = with pkgs;
    [
      # Media/Video
      evince # PDF Viewer
      gnome.eog # Image Viewer
      mpv # Video Player
      motrix # Download Manager
      gnome-text-editor # Text Editor
    ]
    ++ (with unstable; [
      # Apps
      bitwarden # Password Manager
      zoom-us # Video Conferencing
      slack # Messaging
      telegram-desktop # Messaging
      anki # Flashcard Program
    ]);

  # Enable Firefox
  firefox.enable = true;

  # Enable Gaming Programs
  gaming.enable = true;

  # Enable Gnome Disks
  programs.gnome-disks.enable = true;
}
