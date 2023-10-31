{
  config,
  lib,
  pkgs,
  unstable,
  inputs,
  vars,
  ...
}: {

  networking.hostName = "nixos"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Select internationalisation properties.
  services.xserver.layout = "us";
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    keyMap = "us";
    #   font = "Lat2-Terminus16";
    #   useXkbConfig = true; # use xkbOptions in tty.
  };

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${vars.user} = {
    # System User
    isNormalUser = true;
    extraGroups = ["wheel" "video" "audio" "networkmanager" "kvm" "libvirtd"];
    initialPassword = "password";
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment = {
    systemPackages = with pkgs;
      [
        # Desktop Environment
        hyprland
        xdg-desktop-portal-hyprland
        xdg-desktop-portal-gtk
        waybar
        #eww-wayland
        rofi-wayland
        # Essential Services
        pipewire
        polkit_gnome
        # Settings Programs
        pavucontrol
        playerctl
        networkmanagerapplet
        blueman
        dconf
        # Text Editor
        neovim
        nixpkgs-fmt
        rnix-lsp
        alejandra
        # Terminal
        kitty
        # Command Line Programs
        wget
        curl
        zip
        unzip
        neofetch
        htop
        git
        gh
        # Programming
        gcc
        gnumake
        valgrind
        gdb
        # Media
        okular # PDF Viewer
        gwenview # Image Viewer
        # Other Programs
        vscode
        anki-bin
        ranger
      ]
      ++ (with unstable; [
        # Apps
        bitwarden
        firefox # Browser
        sddm
        discord
        yuzu-early-access
      ]);
  };

  programs.dconf.enable = true;


  # Fonts
  fonts = {
    fontDir.enable = true;
    enableDefaultFonts = true;
    fonts = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      liberation_ttf
      google-fonts
      corefonts
      vistafonts
      (nerdfonts.override {fonts = ["CascadiaCode"];})
    ];
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.s
  networking.firewall.enable = true;
  networking.firewall.checkReversePath = false;

  networking.firewall = {
    # if packets are still dropped, they will show up in dmesg
    logReversePathDrops = true;
    # wireguard trips rpfilter up
    extraCommands = ''
      ip46tables -t mangle -I nixos-fw-rpfilter -p udp -m udp --sport 51820 -j RETURN
      ip46tables -t mangle -I nixos-fw-rpfilter -p udp -m udp --dport 51820 -j RETURN
    '';
    extraStopCommands = ''
      ip46tables -t mangle -D nixos-fw-rpfilter -p udp -m udp --sport 51820 -j RETURN || true
      ip46tables -t mangle -D nixos-fw-rpfilter -p udp -m udp --dport 51820 -j RETURN || true
    '';
  };

  nix = {
    # Nix Package Manager Settings
    settings = {
      auto-optimise-store = true;
      experimental-features = ["nix-command" "flakes"];
      keep-outputs = true;
      keep-derivations = true;
    };
    gc = {
      # Garbage Collection
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    package = pkgs.nixVersions.unstable; # Enable Flakes
    registry.nixpkgs.flake = inputs.nixpkgs;
  };

  nixpkgs.config.allowUnfree = true; # Allow Proprietary Software.

  home-manager.users.${vars.user} = {
    # Home-Manager Settings
    home = {
      stateVersion = "23.05";
    };

    programs = {
      home-manager.enable = true;
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
