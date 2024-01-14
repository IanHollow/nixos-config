{
  pkgs,
  unstable,
  config,
  lib,
  ...
}:
with lib; {
  # Make sure that hyprland is enabled
  config = mkMerge [
    (mkIf (config.hyprland.enable) {
      # set environment variables for the hyprland session
      environment.sessionVariables =
        # TODO: change this if statement to check if a multi-gpu setup is being used (the multi-gpu setup is another TODO)
        # Check if NVIDIA is the only GPU used (not a full proof solution yet read the todo above)
        # Merge the base variables with the extra variables
        mkMerge [
          # Base Variables
          {
            # XDG Specifications
            XDG_SESSION_TYPE = "wayland"; # Also needed for NVIDIA GPUs
            XDG_CURRENT_DESKTOP = "Hyprland";
            XDG_SESSION_DESKTOP = "Hyprland";

            # Qt Variables
            QT_AUTO_SCREEN_SCALE_FACTOR = "1";
            QT_QPA_PLATFORM = "wayland";
            QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";

            # GTK Variables
            GDK_BACKEND = "wayland";

            # Others
            # CLUTTER_BACKEND = "wayland";
            # SDL_VIDEODRIVER = "wayland";

            # Java
            _JAVA_AWT_WM_NONREPARENTING = "1";

            # ozone-based browsers & electron apps
            NIXOS_OZONE_WL = "1";
          }

          # NVIDIA Variables
          (
            if (config.nvidia_gpu.enable)
            then
              mkMerge [
                # NVIDIA Variables
                {
                  LIBVA_DRIVER_NAME = "nvidia";
                  GBM_BACKEND = "nvidia-drm";
                  __GLX_VENDOR_LIBRARY_NAME = "nvidia";
                  WLR_NO_HARDWARE_CURSORS = "1";
                }

                # VRR Variables for NVIDIA
                (
                  if (config.hyprland.monitors.primary.vrr)
                  then {
                    __GL_GSYNC_ALLOWED = "1";
                    __GL_VRR_ALLOWED = "1";
                  }
                  else {
                    __GL_GSYNC_ALLOWED = "0";
                    __GL_VRR_ALLOWED = "0";
                  }
                )
              ]
            else {}
          )

          # Extra Variables
          (
            if (config.hyprland.allowTearing)
            then {
              WLR_DRM_NO_ATOMIC = "1";
            }
            else {}
          )
        ];
    })
  ];
}
