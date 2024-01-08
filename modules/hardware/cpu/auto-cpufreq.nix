{
  pkgs,
  unstable,
  config,
  lib,
  ...
}:
with lib; {
  # Define options for auto-cpufreq
  options.auto-cpufreq = {
    # Enable auto-cpufreq service
    enable = mkOption {
      type = types.bool;
      default = config.laptop.enable;
      description = "Enable auto-cpufreq service";
    };
  };

  # Define auto-cpufreq config
  config = mkIf (config.auto-cpufreq.enable) {
    services.auto-cpufreq = {
      enable = true;

      settings = {
        battery = {
          governor = "powersave";
          turbo = "never";
        };
        charger = {
          governor = "performance";
          turbo = "auto";
        };
      };
    };
  };
}
