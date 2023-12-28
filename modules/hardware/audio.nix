{
  lib,
  config,
  pkgs,
  unstable,
  vars,
  ...
}:
with lib; {
  options = {
    audio = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable audio support";
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

    # Disable pulseaudio as it conflicts with pipewire
    hardware.pulseaudio.enable = mkForce false;

    # Add user to audio group
    users.users.${vars.user}.extraGroups = ["audio"];
  };
}
