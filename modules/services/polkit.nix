{pkgs, ...}: {
  # Enable polkit
  security.polkit.enable = true;

  # Enable polkit-kde
  environment.systemPackages = with pkgs; [
    polkit-kde-agent
  ];

  # Start Polkit Service
  systemd = {
    user.services.polkit-kde-agent-authentication-agent-1 = {
      description = "polkit-kde-agent-authentication-agent-1";
      wantedBy = ["graphical-session.target"];
      wants = ["graphical-session.target"];
      after = ["graphical-session.target"];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit-kde-agent}/libexec/polkit-kde-agent-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };
}
