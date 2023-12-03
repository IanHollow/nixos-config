{
  pkgs,
  unstable,
  lib,
  ...
}: {
  imports =
    [./hardware-configuration.nix]
    ++ (import ../../modules/hardware)
    ++ (import ../../modules/desktops)
    ++ (import ../../modules/editors)
    ++ (import ../../modules/input-components)
    ++ (import ../../modules/programming)
    ++ (import ../../modules/programs)
    ++ (import ../../modules/security)
    ++ (import ../../modules/services)
    ++ (import ../../modules/shell)
    ++ (import ../../modules/theming);

  # Desktop Evironment / Desktop Manager
  hyprland.enable = true;
  # gnome.enable = true;
  # plasma.enable = true;

  # Enable the GPU
  nvidia_gpu.enable = true;

  # Enable Audio
  pipewire.enable = true;

  # Enable bootloader
  boot = {
    # Boot Options
    loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
      grub = {
        # Grub Dual Boot
        enable = true;
        devices = ["nodev"];
        efiSupport = true;
        useOSProber = true; # Find All boot Options
        configurationLimit = 10;
        default = 0; # chooses nixos for boot (set 2 to boot to another OS if installed)
      };
      timeout = 5;
    };
    kernelPackages = pkgs.linuxPackages_6_5;
  };

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
      firefox # Browser
      bitwarden # Password Manager
      zoom-us # Video Conferencing
      slack # Messaging
      telegram-desktop # Messaging
    ]);
}
