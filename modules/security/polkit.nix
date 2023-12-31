{
  pkgs,
  config,
  lib,
  ...
}:
with lib; {
  options.polkit = {
    enable = mkEnableOption "Enable polkit";
    service.enable = mkEnableOption "Enable polkit service to start on boot. Can be handled in other ways if desired.";
  };

  config = mkIf (config.polkit.enable) {
    # Enable polkit
    security.polkit.enable = true;

    # Install polkit_gnome
    environment.systemPackages = with pkgs; [
      polkit_gnome
    ];

    # Start Polkit Service
    systemd.user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = ["graphical-session.target"];
      wants = ["graphical-session.target"];
      after = ["graphical-session.target"];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };
}
