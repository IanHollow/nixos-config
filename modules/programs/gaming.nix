{
  pkgs,
  unstable,
  vars,
  config,
  lib,
  ...
}:
with lib; {
  options.gaming = {
    enable = mkEnableOption "Enable steam";
  };

  config = let
    gamescope_pkg = pkgs.gamescope;
    gamescope_env = mkMerge [
      {
        WLR_RENDERER = "vulkan";
        # DXVK_HDR = "1"; # TODO: make based on monitor config
        # ENABLE_GAMESCOPE_WSI = "1";
        # WINE_FULLSCREEN_FSR = "1";
        # WINEFSYNC = "1";
        # WINE_VK_VULKAN_ONLY = "1";
        # WINE_VK_USE_FSR = "1";
      }

      ( # Nvidia Prime Offload
        if config.nvidia_gpu.prime_render_offload.enable
        then {
          __NV_PRIME_RENDER_OFFLOAD = "1";
          __NV_PRIME_RENDER_OFFLOAD_PROVIDER = "NVIDIA-G0";
          __GLX_VENDOR_LIBRARY_NAME = "nvidia";
          __VK_LAYER_NV_optimus = "NVIDIA_only";
          LIBVA_DRIVER_NAME = "nvidia";
        }
        else {}
      )
    ];
  in
    mkIf (config.gaming.enable) {
      hardware.opengl.extraPackages = [gamescope_pkg];

      programs = {
        steam = {
          enable = true;
          package = unstable.steam;
          gamescopeSession = {
            enable = true;
            env = gamescope_env;
          };
        };

        gamescope = {
          enable = true;
          package = gamescope_pkg;
          env = gamescope_env;
        };

        gamemode = {
          enable = true;
          enableRenice = true;
        };
      };

      environment.systemPackages = [
        # Steam
        unstable.protonup-qt # proton package manager
        pkgs.vkbasalt # a reshader
        pkgs.mangohud # display system info on top of games
        pkgs.goverlay # tool for mangohud

        # Lutris
        pkgs.lutris

        # Wine
        pkgs.protontricks
        pkgs.winePackages.waylandFull
        pkgs.winetricks
        pkgs.gnome.zenity
      ];
    };
}
