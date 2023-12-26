{
  lib,
  config,
  pkgs,
  unstable,
  ...
}:
with lib; {
  options = {
    audio = {
      # Condition if host uses an Nvidia GPU
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };

  # TODO: add some sort of mic improvement to remove background noise

  config = mkIf (config.audio.enable) {
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
      wireplumber.enable = true;
    };

    # rtkit is optional but recommended
    security.rtkit.enable = true;
    # Remove sound.enable or turn it off if you had it set previously, it seems to cause conflicts with pipewire
    sound.enable = false;
    # Disable pulseaudio, it conflicts with pipewire too.
    hardware.pulseaudio.enable = mkForce false;
  };
}
