{
  lib,
  config,
  pkgs,
  unstable,
  vars,
  ...
}:
with lib; {
  options.audio = {
    # Enable audio support
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable audio support";
    };

    # Noise Suppression for Voice
    NoiseSuppressionForVoice = {
      # Enable noise suppression
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable noise suppression for voice";
      };

      # Stereo or Mono microphone for noise suppression
      stereo = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Use stereo microphone for noise suppression.
          Even if you have a stereo microphone you probably do need to enable this.
        '';
      };
    };
  };

  config = mkIf (config.audio.enable) {
    services.pipewire = {
      # Enable all audio services
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

    # Noise suppression for voice
    # Config based on GitHub README from: https://github.com/werman/noise-suppression-for-voice
    environment.etc = let
      # Define config for pipewire
      json = pkgs.formats.json {};
      pipewire_rnnoise_config = {
        "context.modules" = [
          {
            "name" = "libpipewire-module-filter-chain";
            "args" = {
              "node.description" = "Noise Canceling Source";
              "media.name" = "Noise Canceling Source";
              "filter.graph" = {
                "nodes" = [
                  {
                    "type" = "ladspa";
                    "name" = "rnnoise";
                    "plugin" = "${pkgs.rnnoise-plugin}/lib/ladspa/librnnoise_ladspa.so";
                    "label" = strings.concatStrings [
                      "noise_suppressor_"
                      (
                        if (config.audio.NoiseSuppressionForVoice.stereo)
                        then "stereo"
                        else "mono"
                      )
                    ];
                    "control" = {
                      "VAD Threshold (%)" = 50.0;
                      "VAD Grace Period (ms)" = 200;
                      "Retroactive VAD Grace (ms)" = 0;
                    };
                  }
                ];
              };
              "capture.props" = {
                "node.name" = "capture.rnnoise_source";
                "node.passive" = true;
                "audio.rate" = 48000;
              };
              "playback.props" = {
                "node.name" = "rnnoise_source";
                "media.class" = "Audio/Source";
                "audio.rate" = 48000;
              };
            };
          }
        ];
      };
    in {
      # Create Config file for pipewire
      "pipewire/pipewire.conf.d/99-input-denoising.conf" = {
        source = mkIf (config.audio.NoiseSuppressionForVoice.enable) (json.generate "99-input-denoising.conf" pipewire_rnnoise_config);
      };
    };
  };
}
