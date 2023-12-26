{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    gcc
    gnumake
    valgrind
    gdb
  ];
}
