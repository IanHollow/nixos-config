{pkgs, unstable, ...}:{
  environment.systemPackages = {
    pkgs.vscode
  }

  # needed for store VS Code auth token
  programs.seahorse.enable = true;
  services.gnome.gnome-keyring.enable = true;
  nixpkgs.config.vscode.commandLineArgs = "--password-store='gnome'";

}