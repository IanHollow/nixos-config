{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    python3
    black # python formatter
    yapf # python formatter
  ];
}
